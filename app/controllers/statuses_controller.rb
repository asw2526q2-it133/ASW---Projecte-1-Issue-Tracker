class StatusesController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_status, only: %i[ show edit update destroy ]

  # GET /statuses or /statuses.json
  def index
    @statuses = Status.all
  end

  # GET /statuses/1 or /statuses/1.json
  def show
  end

  # GET /statuses/new
  def new
    @status = Status.new
  end

  # GET /statuses/1/edit
  def edit
  end

  # POST /statuses or /statuses.json
  def create
    @status = Status.new(status_params)

    respond_to do |format|
      if @status.save
        # CAMBIO: Redirige a la lista en lugar de a la vista "show"
        format.html { redirect_to statuses_url, notice: "El estado se creó correctamente." }
        format.json { render :show, status: :created, location: @status }
      else
        # Esto es lo que hace que salgan los errores rojos en el formulario (duplicados)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /statuses/1 or /statuses/1.json
  def update
    respond_to do |format|
      if @status.update(status_params)
        # CAMBIO: Redirige a la lista
        format.html { redirect_to statuses_url, notice: "El estado se actualizó correctamente.", status: :see_other }
        format.json { render :show, status: :ok, location: @status }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statuses/1 or /statuses/1.json
  def destroy
    # CAMBIO: Quitamos la exclamación (!) para poder capturar nuestro bloqueo de seguridad
    if @status.destroy
      respond_to do |format|
        format.html { redirect_to statuses_url, notice: "El estado fue eliminado.", status: :see_other }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        # Si el modelo cancela el borrado, mostramos el mensaje de error (alert)
        format.html { redirect_to statuses_url, alert: @status.errors.full_messages.to_sentence, status: :see_other }
        format.json { render json: @status.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_status
      @status = Status.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def status_params
      params.expect(status: [ :name, :color ])
    end
end
