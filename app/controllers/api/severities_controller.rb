class Api::SeveritiesController < Api::ApplicationController
  before_action :set_severity, only: [:show, :update, :destroy]

  # GET /api/severities
  def index
    @severities = Severity.all
    render json: @severities, status: :ok
  end

  # GET /api/severities/:id
  def show
    render json: @severity, status: :ok
  end

  # POST /api/severities
  def create
    @severity = Severity.new(severity_params)
    
    if @severity.save
      render json: @severity, status: :created
    else
      render json: { errors: @severity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/severities/:id
  def update
    if @severity.update(severity_params)
      render json: @severity, status: :ok
    else
      render json: { errors: @severity.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/severities/:id
  def destroy
    issues_on_use = Issue.where(severity_id: @severity.id)

    if issues_on_use.any?
      replacement_id = params[:replacement_id]
      
      if replacement_id.blank?
        return render json: { error: "Aquesta severitat s'està utilitzant. Cal proporcionar un 'replacement_id' per reassignar les issues." }, status: :unprocessable_entity
      end

      if replacement_id.to_s == @severity.id.to_s
        return render json: { error: "La severitat de substitució no pot ser la mateixa que vas a esborrar." }, status: :unprocessable_entity
      end

      unless Severity.exists?(replacement_id)
        return render json: { error: "La severitat de substitució proporcionada no existeix." }, status: :not_found
      end
    end

    Severity.transaction do
      issues_on_use.update_all(severity_id: params[:replacement_id]) if issues_on_use.any?

      unless @severity.destroy
        raise ActiveRecord::Rollback 
      end
    end

    if @severity.destroyed?
      head :no_content
    else
      render json: { error: @severity.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def set_severity
    @severity = Severity.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Severitat no trobada' }, status: :not_found
  end

  def severity_params
    params.require(:severity).permit(:name, :color)
  end
end