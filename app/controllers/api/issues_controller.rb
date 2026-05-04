class Api::IssuesController < Api::ApplicationController
  before_action :set_issue, only: [:show, :update, :destroy]
  before_action :authorize_issue_creator!, only: [:update, :destroy]

  # GET /api/issues
  def index
    @issues = Issue.all
    render json: @issues.as_json(include: [:user, :status, :issue_type, :priority, :severity])
  end

  # GET /api/issues/:id
  def show
    render json: @issue.as_json(include: [:user, :status, :issue_type, :priority, :severity, :comments])
  end

  # POST /api/issues
  def create
    @issue = Issue.new(issue_params)
    @issue.user = current_user

    if @issue.save
      render json: @issue, status: :created
    else
      render json: { errors: @issue.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /api/issues/:id
  def update
    if @issue.update(issue_params)
      render json: @issue, status: :ok
    else
      render json: { errors: @issue.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/issues/:id
  def destroy
    @issue.destroy
    head :no_content
  end

  private

  def set_issue
    @issue = Issue.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Issue no encontrada' }, status: :not_found
  end

  def authorize_issue_creator!
    unless @issue.user == current_user
      render json: { error: 'No tienes permiso para modificar esta issue' }, status: :forbidden
    end
  end

  def issue_params
    params.require(:issue).permit(
      :subject, :description, :issue_type_id, :severity_id,
      :priority_id, :status_id, :assignee_id, :due_date,
      tag_ids: [], watcher_ids: [], attachments: []
    )
  end
end