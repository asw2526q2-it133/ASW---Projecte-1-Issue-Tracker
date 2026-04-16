class IssueTypesController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_issue_type, only: %i[ show edit update destroy ]

  # GET /issue_types or /issue_types.json
  def index
    @issue_types = IssueType.all
  end

  # GET /issue_types/1 or /issue_types/1.json
  def show
  end

  # GET /issue_types/new
  def new
    @issue_type = IssueType.new
  end

  # GET /issue_types/1/edit
  def edit
  end

  # POST /issue_types or /issue_types.json
  def create
    @issue_type = IssueType.new(issue_type_params)

    respond_to do |format|
      if @issue_type.save
        format.html { redirect_to issue_types_url, notice: "Issue type was successfully created." }
        format.json { render :show, status: :created, location: @issue_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @issue_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /issue_types/1 or /issue_types/1.json
  def update
    respond_to do |format|
      if @issue_type.update(issue_type_params)
        format.html { redirect_to issue_types_url, notice: "Issue type was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @issue_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @issue_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /issue_types/1 or /issue_types/1.json
  def destroy
    @issue_type.destroy

    respond_to do |format|
      format.html { redirect_to issue_types_path, notice: "Issue type was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def destroy
    # 1. Buscamos issues que usen el nombre de este tipo (parche temporal por ser Strings)
    issues_en_uso = Issue.where(issue_type: @issue_type.name)

    if issues_en_uso.any?
      # 2. Si hay issues, BLOQUEAMOS y mandamos un ALERT (mensaje de error)
      respond_to do |format|
        format.html {
          redirect_to issue_types_url,
          alert: "¡Error! No se puede borrar el tipo '#{@issue_type.name}' porque está asignado a #{issues_en_uso.count} issue(s)."
        }
        format.json { head :unprocessable_entity }
      end
    else
      # 3. Si no hay issues, procedemos al borrado real
      @issue_type.destroy
      respond_to do |format|
        format.html { redirect_to issue_types_url, notice: "Tipo eliminado correctamente." }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue_type
      @issue_type = IssueType.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def issue_type_params
      params.expect(issue_type: [ :name, :color ])
    end
end
