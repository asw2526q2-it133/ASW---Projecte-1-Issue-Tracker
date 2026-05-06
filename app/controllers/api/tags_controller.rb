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
    # No cal replacement_id perquè els tags no són obligatoris per a una Issue
    if @tag.destroy
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
    # Afegim el :color als paràmetres permesos
    params.require(:tag).permit(:name, :color)
  end
end