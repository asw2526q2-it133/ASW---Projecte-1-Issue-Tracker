class IssuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_issue, only: %i[ show edit update destroy ]

  before_action :authorize_issue_creator!, only: %i[ edit update destroy ]

  # GET /issues or /issues.json
  def index
    @issues = Issue.all

    # Filtros cruzados
    @issues = @issues.filter_by_status(params[:statuses])
    @issues = @issues.filter_by_priority(params[:priorities])
    @issues = @issues.filter_by_severity(params[:severities])
    @issues = @issues.filter_by_type(params[:types])

    # Búsqueda por texto (opcional si la usas)
    if params[:search].present?
      t = "%#{params[:search].downcase}%"
      @issues = @issues.where("LOWER(subject) LIKE :q OR LOWER(description) LIKE :q", q: t)
    end

    @issues = @issues.reorder("#{sort_column} #{sort_direction}")
  end

  # GET /issues/1 or /issues/1.json
  def show
    @issue = Issue.includes(comments: :user, activities: :user).find(params[:id])
  end

  # GET /issues/new
  def new
    @issue = Issue.new
    @types = IssueType.all
    @priorities = Priority.all
    @severities = Severity.all
    @statuses = Status.all
    @assignable_users = User.all
    @tags = Tag.all
  end

  # GET /issues/1/edit
  def edit
    @issue = Issue.find(params[:id])
    @types = IssueType.all
    @priorities = Priority.all
    @severities = Severity.all
    @statuses = Status.all
    @assignable_users = User.all
    @tags = Tag.all
  end

  # POST /issues or /issues.json
  def create
    @issue = Issue.new(issue_params)
    @types = IssueType.all
    @priorities = Priority.all
    @severities = Severity.all
    @statuses = Status.all
    @assignable_users = User.all
    @tags = Tag.all

    @issue.user = current_user

    Rails.logger.debug "PARAMS: #{params.inspect}"
    Rails.logger.debug "ATTACHMENTS: #{params[:issue][:attachments].inspect}"

    respond_to do |format|
      if @issue.save
        format.html { redirect_to @issue, notice: "Issue was successfully created." }
        format.json { render :show, status: :created, location: @issue }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /issues/1 or /issues/1.json
  def update
    respond_to do |format|
      if @issue.update(issue_params)

        if params[:issue] && params[:issue][:remove_attachments].present?
          params[:issue][:remove_attachments].each do |attachment_id|
            attachment = @issue.attachments.find_by(id: attachment_id)
            attachment.purge if attachment
          end
        end

        cambios = @issue.saved_changes.except(:updated_at).keys.map(&:humanize).join(", ")
        desc_accion = cambios.present? ? "updated #{cambios}" : "updated the issue"

        Activity.create(
          issue: @issue,
          user: current_user,
          action: desc_accion
        )

        format.html { redirect_to @issue, notice: "Issue was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @issue }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /issues/1 or /issues/1.json
  def destroy
    @issue.destroy!

    respond_to do |format|
      format.html { redirect_to issues_path, notice: "Issue was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # GET /issues/bulk
  def bulk
    # Solo renderiza la vista
  end

  # POST /issues/create_bulk
  def create_bulk
    titles = params[:bulk_data].split("\n").map(&:strip).reject(&:empty?)

    if titles.any?
      issues_to_create = titles.map { |title| {
        subject: title,
        status_id: Status.first&.id,
        priority_id: Priority.first&.id,
        severity_id: Severity.first&.id,
        issue_type_id: IssueType.first&.id,
        user_id: current_user.id,
        created_at: Time.current,
        updated_at: Time.current
        } }

      Issue.create(issues_to_create)

      redirect_to issues_path, notice: "¡Se han creado #{titles.size} issues correctamente!"
    else
      redirect_to bulk_issues_path, alert: "Por favor, escribe al menos un título."
    end
  end

  private
    def authorize_issue_creator!
      unless @issue.user == current_user
        redirect_to @issue, alert: "No tens permís per modificar o esborrar aquesta issue. Només el creador ho pot fer."
      end
    end

    def set_issue
      @issue = Issue.find(params[:id])
    end

    def sort_column
      valid_columns = %w[issue_type_id severity_id priority_id subject status_id updated_at user_id due_date]

      valid_columns.include?(params[:sort]) ? params[:sort] : "updated_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def issue_params
      params.expect(issue: [
        :subject,
        :description,
        :issue_type_id,
        :severity_id,
        :priority_id,
        :status_id,
        :assignee_id,
        :due_date, tag_ids: [],
        attachments: [],
        remove_attachments: []
      ])
    end
end
