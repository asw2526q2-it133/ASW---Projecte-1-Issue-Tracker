class Api::IssueTypesController < Api::ApplicationController
  before_action :set_issue_type, only: [:show, :update, :destroy]

  # GET /api/issue_types
  def index
    @issue_types = IssueType.all
    render json: @issue_types, status: :ok
  end

  # GET /api/issue_types/:id
  def show
    render json: @issue_type, status: :ok
  end

  # POST /api/issue_types
  def create
    @issue_type = IssueType.new(issue_type_params)
    
    if @issue_type.save
      render json: @issue_type, status: :created
    else
      render json: { errors: @issue_type.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/issue_types/:id
  def update
    if @issue_type.update(issue_type_params)
      render json: @issue_type, status: :ok
    else
      render json: { errors: @issue_type.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/issue_types/:id
  def destroy
    issues_on_use = Issue.where(issue_type_id: @issue_type.id)

    if issues_on_use.any?
      replacement_id = params[:replacement_id]
      
      if replacement_id.blank?
        return render json: { error: "Aquest tipus s'està utilitzant. Cal proporcionar un 'replacement_id' per reassignar les issues." }, status: :unprocessable_entity
      end

      if replacement_id.to_s == @issue_type.id.to_s
        return render json: { error: "El tipus de substitució no pot ser el mateix que vas a esborrar." }, status: :unprocessable_entity
      end

      unless IssueType.exists?(replacement_id)
        return render json: { error: "El tipus de substitució proporcionat no existeix." }, status: :not_found
      end
    end

    IssueType.transaction do
      # Reasignem les issues al nou tipus si cal
      issues_on_use.update_all(issue_type_id: params[:replacement_id]) if issues_on_use.any?

      # Eliminem el tipus original
      unless @issue_type.destroy
        # Si falla, fem rollback
        raise ActiveRecord::Rollback 
      end
    end

    if @issue_type.destroyed?
      head :no_content
    else
      render json: { error: @issue_type.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def set_issue_type
    @issue_type = IssueType.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Issue Type no encontrado' }, status: :not_found
  end

  def issue_type_params
    params.require(:issue_type).permit(:name, :color)
  end
end