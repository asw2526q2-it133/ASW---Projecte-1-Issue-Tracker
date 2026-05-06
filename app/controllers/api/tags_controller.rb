class Api::TagsController < Api::ApplicationController
  before_action :set_tag, only: [:show, :update, :destroy]

  # GET /api/tags
  def index
    @tags = Tag.all
    render json: @tags, status: :ok
  end

  # GET /api/tags/:id
  def show
    render json: @tag, status: :ok
  end

  # POST /api/tags
  def create
    @tag = Tag.new(tag_params)
    
    if @tag.save
      render json: @tag, status: :created
    else
      render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/tags/:id
  def update
    if @tag.update(tag_params)
      render json: @tag, status: :ok
    else
      render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/tags/:id
  def destroy
    on_use = @tag.issue_tags

    if on_use.any?
      replacement_id = params[:replacement_id]
      
      if replacement_id.blank?
        return render json: { error: "Aquest tag s'està utilitzant. Cal proporcionar un 'replacement_id' per reassignar les issues." }, status: :unprocessable_entity
      end

      if replacement_id.to_s == @tag.id.to_s
        return render json: { error: "El tag de substitució no pot ser el mateix que vas a esborrar." }, status: :unprocessable_entity
      end

      unless Tag.exists?(replacement_id)
        return render json: { error: "El tag de substitució proporcionat no existeix." }, status: :not_found
      end
    end

    Tag.transaction do
      if on_use.any?
        # Busquem les issues que ja tenen el tag de substitució per evitar duplicats
        issues_with_replacement = IssueTag.where(tag_id: replacement_id).pluck(:issue_id)
        
        # Eliminem els duplicats
        on_use.where(issue_id: issues_with_replacement).destroy_all
        
        # Reasignem 
        on_use.update_all(tag_id: replacement_id)
      end

      unless @tag.destroy
        raise ActiveRecord::Rollback 
      end
    end

    if @tag.destroyed?
      head :no_content
    else
      render json: { error: @tag.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Tag no trobat' }, status: :not_found
  end

  def tag_params
    params.require(:tag).permit(:name, :color)
  end
end