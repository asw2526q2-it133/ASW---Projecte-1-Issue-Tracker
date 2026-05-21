class Api::ApplicationController < ActionController::API
  before_action :authenticate_api_key!

  private

  def authenticate_api_key!
    api_key = request.headers["X-Api-Key"]

    @current_user = User.find_by(api_key: api_key)

    unless @current_user
      render json: { error: "No autoritzat. Api-Key invàlida o absent" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
