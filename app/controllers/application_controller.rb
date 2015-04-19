class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def page_not_found
    render json: { 'message' => 'page not found' }, status: 404
  end
end
