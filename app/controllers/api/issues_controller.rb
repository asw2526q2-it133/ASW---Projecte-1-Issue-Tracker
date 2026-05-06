class Api::IssuesController < Api::ApplicationController
  # MODIFICAT: Afegits els nous mètodes al set_issue
  before_action :set_issue, only: [ :show, :update, :destroy, :add_watcher, :remove_watcher, :add_attachment, :remove_attachment ]
  # before_action :authorize_issue_creator!, only: [ :update, :destroy ]

  # GET /api/issues
  def index
    @issues = Issue.all

    issues_json = @issues.as_json(
      except: [ :created_at, :updated_at ],
      include: {
        user: { only: [ :id, :name, :email ] },
        assignee: { only: [ :id, :name, :email ] },
        status: { only: [ :id, :name ] },
        issue_type: { only: [ :id, :name ] },
        priority: { only: [ :id, :name ] },
        severity: { only: [ :id, :name ] }
      }
    )

    render json: issues_json, status: :ok
  end

  # GET /api/issues/:id
  def show
    issue_json = @issue.as_json(
      include: {
        user: { only: [ :id, :name, :email ] },
        assignee: { only: [ :id, :name, :email ] },
        status: { only: [ :id, :name ] },
        issue_type: { only: [ :id, :name ] },
        priority: { only: [ :id, :name ] },
        severity: { only: [ :id, :name ] },
        watchers: { only: [ :id, :name, :email ] },
        comments: {
          include: {
            user: { only: [ :id, :name ] }
          }
        },
        activities: {}
      }
    )

    if @issue.respond_to?(:attachments) && @issue.attachments.attached?
      issue_json[:attachments] = @issue.attachments.map do |attachment|
        {
          id: attachment.id,
          filename: attachment.filename.to_s,
          url: url_for(attachment)
        }
      end
    else
      issue_json[:attachments] = []
    end

    render json: issue_json, status: :ok
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
    # 1. Assignem els valors nous a memòria sense guardar-los encara
    @issue.assign_attributes(issue_params)

    # 2. Busquem qualsevol comentari nou que s'estigui intentant crear
    # i li assignem automàticament l'usuari que fa la petició
    @issue.comments.select(&:new_record?).each do |comment|
      comment.user = current_user
    end

    # 3. Guardem la issue i els comentaris a la base de dades
    if @issue.save
      # CORREGIT: Canviat description per action
      @issue.activities.create(action: "Issue actualitzada per #{current_user.name}")

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

  # POST /api/issues/:id/watchers
  def add_watcher
    user = User.find(params[:watcher_id])
    unless @issue.watchers.include?(user)
      @issue.watchers << user
      # CORREGIT: Canviat description per action
      @issue.activities.create(action: "Usuari #{user.name} afegit com a watcher per #{current_user.name}")
    end
    render json: { message: "Watcher afegit correctament" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Usuari no trobat" }, status: :not_found
  end

  # DELETE /api/issues/:id/watchers/:watcher_id
  def remove_watcher
    user = User.find(params[:watcher_id])
    if @issue.watchers.delete(user)
      # Registrem l'activitat fent servir 'action'
      @issue.activities.create(action: "Usuari #{user.name} eliminat com a watcher per #{current_user.name}")
      head :no_content
    else
      render json: { error: "L'usuari no és watcher d'aquesta issue" }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Usuari no trobat" }, status: :not_found
  end

  # POST /api/issues/:id/attachments
  def add_attachment
    if params[:attachment].present?
      @issue.attachments.attach(params[:attachment])
      # CORREGIT: Canviat description per action
      @issue.activities.create(action: "Fitxer adjunt afegit per #{current_user.name}")
      render json: { message: "Fitxer adjuntat correctament" }, status: :ok
    else
      render json: { error: "Cap fitxer proporcionat" }, status: :unprocessable_entity
    end
  end

  # DELETE /api/issues/:id/attachments/:attachment_id
  def remove_attachment
    attachment = @issue.attachments.find(params[:attachment_id])
    attachment.purge
    # CORREGIT: Canviat description per action
    @issue.activities.create(action: "Fitxer adjunt eliminat per #{current_user.name}")
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Fitxer no trobat" }, status: :not_found
  end

  # --------------------------------------------------

  private

  def set_issue
    @issue = Issue.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Issue no encontrada" }, status: :not_found
  end

  def authorize_issue_creator!
    unless @issue.user == current_user
      render json: { error: "No tienes permiso para modificar esta issue" }, status: :forbidden
    end
  end

  def issue_params
    params.require(:issue).permit(
      :subject, :description, :issue_type_id, :severity_id,
      :priority_id, :status_id, :assignee_id, :due_date,
      tag_ids: [], watcher_ids: [], attachments: [],
      comments_attributes: [ :id, :content, :_destroy ]
    )
  end
end
