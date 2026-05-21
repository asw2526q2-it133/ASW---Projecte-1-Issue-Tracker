class Api::IssuesController < Api::ApplicationController
  # MODIFICAT: Afegits els nous mètodes al set_issue
  before_action :set_issue, only: [ :show, :update, :destroy, :add_watcher, :remove_watcher, :add_attachment, :remove_attachment ]
  # before_action :authorize_issue_creator!, only: [ :update, :destroy ]

  # GET /api/issues
 def index
    @issues = Issue.left_outer_joins(:issue_type, :status, :priority, :severity)

    # FILTRATGE PER NOM (Filtres "include")
    @issues = @issues.where(issue_types: { name: params[:type] }) if params[:type].present?
    @issues = @issues.where(statuses: { name: params[:status] }) if params[:status].present?
    @issues = @issues.where(priorities: { name: params[:priority] }) if params[:priority].present?
    @issues = @issues.where(severities: { name: params[:severity] }) if params[:severity].present?

    # CERCA (Subject i Description)
    if params[:q].present?
      search_term = "%#{params[:q]}%"
      @issues = @issues.where("issues.subject LIKE ? OR issues.description LIKE ?", search_term, search_term)
    end

    # ORDENACIÓ PER NOM O DATA
    # l'ordenació de tipus, estat, etc., es fa pel camp 'name' de la taula relacionada
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

    # SERIALITZACIÓ I RESPOSTA
    issues_json = @issues.as_json(
      include: {
        user: { only: [ :id, :name, :email ] },
        assignee: { only: [ :id, :name, :email ] },
        status: { only:[ :id, :name ] },
        issue_type: { only: [ :id, :name ] },
        priority: { only: [ :id, :name ] },
        severity: { only:[ :id, :name ] }
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
        activities: {
          include: {
            user: { only: [ :id, :name ] }
          }
        }
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
  Issue.transaction do
    begin

      status    = Status.find_by!(name: params[:status])
      issue_type = IssueType.find_by!(name: params[:type])
      priority  = Priority.find_by!(name: params[:priority])
      severity  = Severity.find_by!(name: params[:severity])

      assignee = nil
      if params[:assignee].present?
        assignee = User.find_by(name: params[:assignee]) || User.find_by(email: params[:assignee])
      end

      @issue = Issue.new(
        subject:     params[:subject],
        description: params[:description],
        due_date:    params[:due_date],
        user:        current_user,
        status:      status,
        issue_type:  issue_type,
        priority:    priority,
        severity:    severity,
        assignee:    assignee
      )

      if params[:tags].present?
        # find_or_create_by crea el tag si no existeix encara
        @issue.tags = Array(params[:tags]).map { |name| Tag.find_or_create_by(name: name) }
      end

      if @issue.save
        render json: @issue.as_json(include: [:user, :status, :issue_type, :priority, :severity, :assignee, :tags]), status: :created
      else
        render json: { errors: @issue.errors.full_messages }, status: :unprocessable_entity
      end

    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "Atribut no trobat: #{e.message}" }, status: :unprocessable_entity
    end
  end
rescue StandardError => e
  render json: { error: "Error intern: #{e.message}" }, status: :internal_server_error
end

  def bulk
    # Acceptem string amb salts de línia o un array directe
    if params[:bulk_data].present?
      titles = params[:bulk_data].split("\n").map(&:strip).reject(&:empty?)
    elsif params[:subjects].is_a?(Array)
      titles = params[:subjects].map(&:strip).reject(&:empty?)
    else
      return render json: { error: "Cal proporcionar 'bulk_data' (string amb salts de línia) o 'subjects' (array de strings)" }, status: :unprocessable_entity
    end

    if titles.empty?
      return render json: { error: "No s'han proporcionat títols vàlids" }, status: :unprocessable_entity
    end

    # dades per a cada issue
    issues_to_create = titles.map do |title|
      {
        subject: title,
        status_id: Status.first&.id,
        priority_id: Priority.first&.id,
        severity_id: Severity.first&.id,
        issue_type_id: IssueType.first&.id,
        user_id: current_user.id,
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    # Creem totes les issues de cop
    created_issues = Issue.create(issues_to_create)

    render json: { 
      message: "S'han creat #{created_issues.size} issues correctament", 
      issues: created_issues.as_json(only: [:id, :subject]) 
    }, status: :created
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
      # AFEGIT: user: current_user
      @issue.activities.create!(action: "Issue actualitzada per #{current_user.name}", user: current_user)

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
      # AFEGIT: user: current_user
      @issue.activities.create!(action: "Usuari #{user.name} afegit com a watcher per #{current_user.name}", user: current_user)
    end
    render json: { message: "Watcher afegit correctament" }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Usuari no trobat" }, status: :not_found
  end

  # DELETE /api/issues/:id/watchers/:watcher_id
  def remove_watcher
    user = User.find(params[:watcher_id])
    if @issue.watchers.delete(user)
      # AFEGIT: user: current_user
      @issue.activities.create!(action: "Usuari #{user.name} eliminat com a watcher per #{current_user.name}", user: current_user)
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
      # AFEGIT: user: current_user
      @issue.activities.create!(action: "Fitxer adjunt afegit per #{current_user.name}", user: current_user)
      render json: { message: "Fitxer adjuntat correctament" }, status: :ok
    else
      render json: { error: "Cap fitxer proporcionat" }, status: :unprocessable_entity
    end
  end

  # DELETE /api/issues/:id/attachments/:attachment_id
  def remove_attachment
    attachment = @issue.attachments.find(params[:attachment_id])
    attachment.purge
    # AFEGIT: user: current_user
    @issue.activities.create!(action: "Fitxer adjunt eliminat per #{current_user.name}", user: current_user)
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
