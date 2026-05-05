class Api::IssuesController < Api::ApplicationController
  before_action :set_issue, only: [ :show, :update, :destroy ]
  before_action :authorize_issue_creator!, only: [ :update, :destroy ]

  # GET /api/issues
  def index
    # Opcional: Si en la primera entrega implementasteis filtros/búsqueda,
    # deberías aplicarlos aquí en lugar de usar Issue.all directamente.
    @issues = Issue.all

    issues_json = @issues.as_json(
      # Solo devolvemos los campos propios de la issue para no sobrecargar
      except: [ :created_at, :updated_at ],
      include: {
        # Creador de la issue
        user: { only: [ :id, :name, :email ] },
        # Usuario asignado
        assignee: { only: [ :id, :name, :email ] },
        # Tablas de configuración
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
        # Creador de la issue
        user: { only: [ :id, :name, :email ] },
        # Usuario asignado (si existe esta relación en tu modelo)
        assignee: { only: [ :id, :name, :email ] },
        # Tablas maestras (settings)
        status: { only: [ :id, :name ] },
        issue_type: { only: [ :id, :name ] },
        priority: { only: [ :id, :name ] },
        severity: { only: [ :id, :name ] },
        # Observadores
        watchers: { only: [ :id, :name, :email ] },
        # Comentarios anidando al autor
        comments: {
          include: {
            user: { only: [ :id, :name ] }
          }
        },
        # Añadido mínimo para la US90 de Taiga
        activities: {}
      }
    )

    if @issue.respond_to?(:attachments) && @issue.attachments.attached?
      issue_json[:attachments] = @issue.attachments.map do |attachment|
        {
          id: attachment.id,
          filename: attachment.filename.to_s,
          # url_for genera la ruta correcta para que se pueda descargar el archivo
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
      tag_ids: [], watcher_ids: [], attachments: []
    )
  end
end
