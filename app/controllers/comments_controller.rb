class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: %i[edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  def create
    @issue = Issue.find(params[:issue_id])
    @comment = @issue.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @issue, notice: "Comentario añadido correctamente."
    else
      redirect_to @issue, alert: "El comentario no puede estar vacío."
    end
  end

  def edit
    # Renderiza la vista edit.html.erb
  end

  def update
    if @comment.update(comment_params)
      redirect_to @comment.issue, notice: "Comentario actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @issue = @comment.issue
    @comment.destroy
    redirect_to @issue, notice: "Comentario eliminado.", status: :see_other
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  # ¡Seguridad! Comprueba que el usuario actual es el dueño del comentario
  def authorize_user!
    unless @comment.user == current_user
      redirect_to @comment.issue, alert: "No tienes permiso para modificar este comentario."
    end
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
