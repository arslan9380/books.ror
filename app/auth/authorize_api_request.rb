class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(headers = {})
    @headers = headers
  end

  def call
    user
  end

  private

  attr_reader :headers

  def user
    return errors.add(:token, 'Invalid Token') if decoded_auth_token == 'Signature verification raised' || decoded_auth_token == 'Nil JSON web token'
    return errors.add(:token, 'Token Expired') if decoded_auth_token == 'Signature has expired'
    @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
    @user.present? ? @user : nil
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
  end

  def http_auth_header
    if headers['Authorization'].present?
      return headers['Authorization'].split(' ').last
    else
      errors.add(:token, 'Missing token')
    end
    nil
  end
end
