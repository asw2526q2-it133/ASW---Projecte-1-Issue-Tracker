class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

def show
    @user = User.find(params[:id])

    sort_column = params[:sort] || "updated_at"
    sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"

    # Creem una funció" reutilitzable per aplicar l'ordenació a QUALSEVOL llista
    apply_sorting = ->(issues) do
      return [] unless issues
      case sort_column
      when "issue_type_id" then issues.joins(:issue_type).order("issue_types.name #{sort_direction}")
      when "severity_id" then issues.joins(:severity).order("severities.name #{sort_direction}")
      when "priority_id" then issues.joins(:priority).order("priorities.name #{sort_direction}")
      when "status_id" then issues.joins(:status).order("statuses.name #{sort_direction}")
      when "subject" then issues.order("subject #{sort_direction}")
      when "updated_at" then issues.order("updated_at #{sort_direction}")
      else issues.order("#{sort_column} #{sort_direction}")
      end
    end

    @open_assigned_issues = apply_sorting.call(@user.assigned_issues.open_assigned)
    
    if @user == current_user
      @watched_issues = apply_sorting.call(@user.watched_issues)
    end

    @comments = @user.comments.includes(:issue).order(created_at: :desc)
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