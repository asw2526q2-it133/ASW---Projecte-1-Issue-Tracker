class Api::PrioritiesController < Api::ApplicationController
  before_action :set_priority, only: [:show, :update, :destroy]

  # GET /api/priorities
  def index
    @priorities = Priority.all
    render json: @priorities, status: :ok
  end

  # GET /api/priorities/:id
  def show
    render json: @priority, status: :ok
  end

  # POST /api/priorities
  def create
    @priority = Priority.new(priority_params)
    
    if @priority.save
      render json: @priority, status: :created
    else
      render json: { errors: @priority.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/priorities/:id
  def update
    if @priority.update(priority_params)
      render json: @priority, status: :ok
    else
      render json: { errors: @priority.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/priorities/:id
  def destroy
    # Comprovem si hi ha issues que facin servir aquesta prioritat
    issues_on_use = Issue.where(priority_id: @priority.id)

    if issues_on_use.any?
      replacement_id = params[:replacement_id]
      
      if replacement_id.blank?
        return render json: { 
          error: "Aquesta prioritat s'està utilitzant. Cal proporcionar un 'replacement_id' per reassignar les issues." 
        }, status: :unprocessable_entity
      end

      if replacement_id.to_s == @priority.id.to_s
        return render json: { 
          error: "La prioritat de substitució no pot ser la mateixa que vas a esborrar." 
        }, status: :unprocessable_entity
      end

      unless Priority.exists?(replacement_id)
        return render json: { 
          error: "La prioritat de substitució proporcionada no existeix." 
        }, status: :not_found
      end
    end

    Priority.transaction do
      # Reassignem les issues a la nova prioritat abans d'esborrar la vella
      issues_on_use.update_all(priority_id: params[:replacement_id]) if issues_on_use.any?

      unless @priority.destroy
        raise ActiveRecord::Rollback 
      end
    end

    if @priority.destroyed?
      head :no_content
    else
      render json: { error: @priority.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def set_priority
    @priority = Priority.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Prioritat no trobada' }, status: :not_found
  end

  def priority_params
    # Permetem name i color, igual que a severities
    params.require(:priority).permit(:name, :color)
  end
end