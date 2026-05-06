class Api::ApplicationController < ActionController::API
  before_action :authenticate_api_key!

  private

  def authenticate_api_key!
    api_key = request.headers["X-Api-Key"] # Extraiem la Api-Key del header

    @current_user = User.find_by(api_key: api_key) # Busquem l'usuari que tingui aquesta clau

    unless @current_user
      render json: { error: "No autorizat. Api-Key invàlida o ausent" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
