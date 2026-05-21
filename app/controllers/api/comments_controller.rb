module Api
  class CommentsController < Api::ApplicationController
    rescue_from ActionController::ParameterMissing do |exception|
      render json: { error: "Error de paràmetres: #{exception.message}" }, status: :bad_request
    end

    before_action :set_issue, only: %i[create]
    before_action :set_comment, only: %i[update destroy]
    before_action :authorize_author!, only: %i[update destroy]

    # POST /api/issues/:issue_id/comments
    def create
      @comment = @issue.comments.build(comment_params)
      @comment.user = @current_user

      if @comment.save
        render json: @comment.as_json(include: { user: { only: %i[id name] } }), status: :created
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH /api/issues/:issue_id/comments/:id
    def update
      if @comment.update(comment_params)
        render json: @comment.as_json(include: { user: { only: %i[id name] } }), status: :ok
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/issues/:issue_id/comments/:id
    def destroy
      @comment.destroy
      head :no_content
    end

    private

    def set_issue
      @issue = Issue.find(params[:issue_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Issue no trobada" }, status: :not_found
    end

    def set_comment
      @comment = Comment.find_by!(id: params[:id], issue_id: params[:issue_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Comentari no trobat en aquesta issue" }, status: :not_found
    end

    def authorize_author!
      unless @comment.user_id == @current_user.id
        render json: { error: "No tens permís per modificar aquest comentari" }, status: :forbidden
      end
    end

    def comment_params
      params.require(:comment).permit(:content)
    end
  end
end
