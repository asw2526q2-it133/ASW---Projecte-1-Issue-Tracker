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
        format.html { redirect_to @severity, notice: "Severity was successfully created." }
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
        format.html { redirect_to @severity, notice: "Severity was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @severity }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @severity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /severities/1 or /severities/1.json
  def destroy
    @severity.destroy!

    respond_to do |format|
      format.html { redirect_to severities_path, notice: "Severity was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_severity
      @severity = Severity.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def severity_params
      params.expect(severity: [ :name, :color ])
    end
end
