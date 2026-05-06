class Api::StatusesController < Api::ApplicationController
  before_action :set_status, only: [:show, :update, :destroy]

  # GET /api/statuses
  def index
    @statuses = Status.all
    render json: @statuses, status: :ok
  end

  # GET /api/statuses/:id
  def show
    render json: @status, status: :ok
  end

  # POST /api/statuses
  def create
    @status = Status.new(status_params)
    
    if @status.save
      render json: @status, status: :created
    else
      render json: { errors: @status.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/statuses/:id
  def update
    if @status.update(status_params)
      render json: @status, status: :ok
    else
      render json: { errors: @status.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/statuses/:id
  def destroy
    # Busquem si hi ha issues que utilitzin aquest estat
    issues_on_use = Issue.where(status_id: @status.id)

    if issues_on_use.any?
      replacement_id = params[:replacement_id]
      
      if replacement_id.blank?
        return render json: { 
          error: "Aquest estat s'està utilitzant. Cal proporcionar un 'replacement_id' per reassignar les issues." 
        }, status: :unprocessable_entity
      end

      if replacement_id.to_s == @status.id.to_s
        return render json: { 
          error: "L'estat de substitució no pot ser el mateix que vas a esborrar." 
        }, status: :unprocessable_entity
      end

      unless Status.exists?(replacement_id)
        return render json: { 
          error: "L'estat de substitució proporcionat no existeix." 
        }, status: :not_found
      end
    end

    Status.transaction do
      # Reassignem les issues a l'estat de substitució
      issues_on_use.update_all(status_id: params[:replacement_id]) if issues_on_use.any?

      unless @status.destroy
        raise ActiveRecord::Rollback 
      end
    end

    if @status.destroyed?
      head :no_content
    else
      render json: { error: @status.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def set_status
    @status = Status.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Estat no trobat' }, status: :not_found
  end

  def status_params
    # Adaptat per permetre :name i :color (o els camps que tinguis a la teva taula statuses)
    params.require(:status).permit(:name, :color)
  end
end