class IssuesController < ApplicationController
  # before_action :authenticate_user!
  before_action :authenticate_user!
  before_action :set_issue, only: %i[ show edit update destroy ]

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

  private
    # Use callbacks to share common setup or constraints between actions.
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

    # Only allow a list of trusted parameters through.
    def issue_params
      params.expect(issue: [
        :subject,
        :description,
        :issue_type_id,
        :severity_id,
        :priority_id,
        :status_id,
        :due_date, tag_ids: [],
        attachments: []
      ])
    end
end
