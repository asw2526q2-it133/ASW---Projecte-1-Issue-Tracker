class SeveritiesController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_severity, only: %i[ show edit update destroy ]

  # GET /severities or /severities.json
  def index
    @severities = Severity.all
  end

  # GET /severities/1 or /severities/1.json
  def show
  end

  # GET /severities/new
  def new
    @severity = Severity.new
  end

  # GET /severities/1/edit
  def edit
  end

  # POST /severities or /severities.json
  def create
    @severity = Severity.new(severity_params)

    respond_to do |format|
      if @severity.save
        format.html { redirect_to severities_path, notice: "Severity was successfully created." }
        format.json { render :show, status: :created, location: @severity }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @severity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /severities/1 or /severities/1.json
  def update
    respond_to do |format|
      if @severity.update(severity_params)
        format.html { redirect_to severities_path, notice: "Severity was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @severity }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @severity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /severities/1 or /severities/1.json
  def destroy
  # Buscamos issues que usen el nombre de esta severidad (parche temporal por ser Strings)
  issues_en_uso = Issue.where(severity: @severity.name)

  if issues_en_uso.any?
    # Si hay issues, BLOQUEAMOS y mandamos un ALERT (mensaje de error)
    respond_to do |format|
      format.html {
        redirect_to severities_url,
        alert: "¡Error! No se puede borrar la severidad '#{@severity.name}' porque está asignada a #{issues_en_uso.count} issue(s)."
      }
      format.json { head :unprocessable_entity }
    end
  else
    # Si no hay issues, procedemos al borrado real
    @severity.destroy
    respond_to do |format|
      format.html { redirect_to severities_url, notice: "Severidad eliminada correctamente." }
      format.json { head :no_content }
      end
  end
  end

  private
    def set_severity
      @severity = Severity.find(params.expect(:id))
    end

    def severity_params
      params.expect(severity: [ :name, :color ])
    end
end
