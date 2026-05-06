# app/controllers/api/users_controller.rb
class Api::UsersController < Api::ApplicationController
  skip_before_action :authenticate_api_key!, only:[:show, :assigned_issues, :comments]

  def show
    @user = User.find(params[:id])
    user_data = @user.as_json(only:[:id, :name, :full_name, :email, :bio])
    user_data[:avatar_url] = @user.avatar.attached? ? url_for(@user.avatar) : nil
    render json: user_data, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Usuari no trobat' }, status: :not_found
  end

  def assigned_issues
    @user = User.find(params[:id])
    render json: @user.assigned_issues.open_assigned.as_json(only:[:id, :subject, :status_id]), status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Usuari no trobat' }, status: :not_found
  end

  def watched_issues
    @user = User.find(params[:id])
    
    # Validació: Només el propi usuari pot veure les seves watched issues
    if current_user == @user
      render json: @user.watched_issues.as_json(only: [:id, :subject, :status_id]), status: :ok
    else
      render json: { error: 'No tens permís per veure les issues observades d\'aquest usuari' }, status: :forbidden
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Usuari no trobat' }, status: :not_found
  end

  def comments
    @user = User.find(params[:id])
    render json: @user.comments.as_json(only: [:id, :content, :created_at, :issue_id]), status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Usuari no trobat' }, status: :not_found
  end

  def update
    @user = User.find(params[:id])
    unless @user == current_user
      return render json: { error: 'No tens permís per editar aquest perfil' }, status: :forbidden
    end

    if @user.update(user_params)
      render json: { message: 'Perfil actualitzat correctament' }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Usuari no trobat' }, status: :not_found
  end

  private

  def user_params
    params.require(:user).permit(:bio, :avatar)
  end
end