class ApplicationController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_user

  def json_payload
    HashWithIndifferentAccess.new(JSON.parse(request.raw_post))
  end

  def json_response(success, status_code, message, object, status = :ok)
    render json: { success: success, status_code: status_code, message: message, data: object }, status: status
  end

  def json_error_response(message, object)
    render json: { message: message, data: object }
  end

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end

end
