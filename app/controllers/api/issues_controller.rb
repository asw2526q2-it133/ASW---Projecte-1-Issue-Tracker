class Api::IssuesController < Api::ApplicationController
  before_action :set_issue, only: [ :show, :update, :destroy ]
  before_action :authorize_issue_creator!, only: [ :update, :destroy ]

# GET /api/issues
  def index
    # 1. Iniciem amb l'scope base i fem joins per poder filtrar/ordenar per noms
    # Fem 'left_outer_joins' per no perdre issues que puguin tenir algun camp buit
    @issues = Issue.left_outer_joins(:issue_type, :status, :priority, :severity)

    # 2. FILTRATGE PER NOM (Filtres "include")
    @issues = @issues.where(issue_types: { name: params[:type] }) if params[:type].present?
    @issues = @issues.where(statuses: { name: params[:status] }) if params[:status].present?
    @issues = @issues.where(priorities: { name: params[:priority] }) if params[:priority].present?
    @issues = @issues.where(severities: { name: params[:severity] }) if params[:severity].present?

    # 3. CERCA (Subject i Description)
    if params[:q].present?
      search_term = "%#{params[:q]}%"
      @issues = @issues.where("issues.subject LIKE ? OR issues.description LIKE ?", search_term, search_term)
    end

    # 4. ORDENACIÓ PER NOM O DATA
    # Ara l'ordenació de tipus, estat, etc., es fa pel camp 'name' de la taula relacionada
    sort_whitelist = {
      "type"     => "issue_types.name",
      "status"   => "statuses.name",
      "priority" => "priorities.name",
      "severity" => "severities.name",
      "issue_no" => "issues.id",
      "modified" => "issues.updated_at",
      "due_date" => "issues.due_date"
    }

    sort_column = sort_whitelist[params[:sort]] || "issues.updated_at"
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"

    @issues = @issues.order("#{sort_column} #{sort_direction}")

    # 5. SERIALITZACIÓ I RESPOSTA
    render json: @issues.as_json(
      include: {
        user: { only: [:id, :name, :email] },
        assignee: { only: [:id, :name, :email] },
        status: { only: [:id, :name] },
        issue_type: { only: [:id, :name] },
        priority: { only: [:id, :name] },
        severity: { only: [:id, :name] }
      }
    ), status: :ok
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
