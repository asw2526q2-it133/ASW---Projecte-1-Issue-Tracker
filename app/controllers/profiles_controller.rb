class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
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
