class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

def show
    issues_base = @user.assigned_issues.open_assigned

    sort_column = params[:sort] || "updated_at"
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    @open_assigned_issues = case sort_column
    when "issue_type_id"
      issues_base.joins(:issue_type).order("issue_types.name #{sort_direction}")
    when "severity_id"
      issues_base.joins(:severity).order("severities.name #{sort_direction}")
    when "priority_id"
      issues_base.joins(:priority).order("priorities.name #{sort_direction}")
    when "status_id"
      issues_base.joins(:status).order("statuses.name #{sort_direction}")
    when "subject"
      issues_base.order("subject #{sort_direction}")
    when "updated_at"
      issues_base.order("updated_at #{sort_direction}")
    else
      issues_base.order("#{sort_column} #{sort_direction}")
    end
  end

  def edit
    unless @user == current_user
      redirect_to profile_path(current_user), alert: "No tienes permiso para editar el perfil de otro usuario."
    end
  end

  def update
    unless @user == current_user
      return redirect_to root_path, alert: "No autorizado."
    end

    if @user.update(profile_params)
      redirect_to profile_path(@user), notice: "Tu perfil se ha actualizado correctamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "El usuario que buscas no existe."
  end

  def profile_params
    params.require(:user).permit(:bio, :avatar)
  end
end