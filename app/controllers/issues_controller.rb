class IssuesController < ApplicationController
  before_action :set_issue, only: %i[ show edit update destroy ]

  # GET /issues or /issues.json
  def index
    @issues = Issue.order(created_at: :desc)

    if params[:search].present?
      termino_busqueda = "%#{params[:search].downcase}%"
      @issues = @issues.where("LOWER(subject) LIKE :query OR LOWER(description) LIKE :query", query: termino_busqueda)
    end

    @issues = @issues.where(status: params[:statuses]) if params[:statuses].present?
    @issues = @issues.where(priority: params[:priorities]) if params[:priorities].present?
    @issues = @issues.where(severity: params[:severities]) if params[:severities].present?

    @issues = @issues.reorder("#{sort_column} #{sort_direction}")
  end

  # GET /issues/1 or /issues/1.json
  def show
  end

  # GET /issues/new
  def new
    @issue = Issue.new
  end

  # GET /issues/1/edit
  def edit
  end

  # POST /issues or /issues.json
  def create
    @issue = Issue.new(issue_params)

    loged_user = User.find_by(name: "roger")

    @issue.user = loged_user

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
      @issue = Issue.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def issue_params
      params.expect(issue: [ :subject, :description, :issue_type, :severity, :priority, :status, :user_id ])
    end

    def sort_column
      %w[issue_type severity priority subject status updated_at user_id].include?(params[:sort]) ? params[:sort] : "updated_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
end
