class CommentsController < ApplicationController
  before_action :set_issue
  before_action :set_comment, medical: [:edit, :update, :destroy]

  def create
    @comment = @issue.comments.build(comment_params)
    @comment.user = current_user # L'autor és l'usuari actual

    if @comment.save
      redirect_to @issue, notice: 'Comentari afegit.'
    else
      redirect_to @issue, alert: 'No s'ha pogut afegir el comentari.'
    end
  end

  def edit
    # Rails buscarà automàticament la vista edit.html.erb
  end

  def update
    if @comment.update(comment_params)
      redirect_to @issue, notice: 'Updated comment.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    redirect_to @issue, notice: 'Deleted comment.'
  end

  private

  def set_issue
    @issue = Issue.find(params[:issue_id])
  end

  def set_comment
    @comment = @issue.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end