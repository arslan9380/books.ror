class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def login
    command = AuthenticateUser.call(auth_params[:email], auth_params[:password])
    if command.success?
      auth_token, user = command.result
      if user.present?
        user.update!(authentication_token: auth_token, fcm_token: params[:user][:fcm_token], status: true)
        profile_picture = user.profile_picture.attached? ? url_for(user.profile_picture) : ''
        json_response(true, 200, 'User successfully logged in.', {
          user: user.as_json.merge(profile_picture: profile_picture)
        })
      else
        json_response(false, 400, 'User not found', {})
      end
    else
      json_response(false, 400, 'Incorrect Email or Password', {})
    end
  end


  def register
    user = User.new(user_params)
    if user.save
      command = AuthenticateUser.call(user_params[:email], user_params[:password])
      if command.success?
        auth_token, user = command.result
        user.update(authentication_token: auth_token)
        profile_picture = user.profile_picture.attached? ? url_for(user.profile_picture) : "no picture uploaded"
        json_response(true, 200, 'User successfully sign up.', {
          user: user.as_json(:except => [:password_digest]).merge(profile_picture: profile_picture)
        })
      else
        json_response(true, 400, command.errors.full_messages.first, {
          user: nil
        })
      end

    else
      json_response(false, 400, user.errors.full_messages.first, {
        user: nil
      })
    end
  end

  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :profile_picture)
    # params.require(:book).permit(:title, :description, :rating)
    # params.fetch(:book, {}).permit(:title, :description, :rating)
  end

end
