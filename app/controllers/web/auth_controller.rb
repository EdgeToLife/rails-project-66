# frozen_string_literal: true

module Web
  class AuthController < ApplicationController
    def callback
      user = authenticate_user(auth)
      sign_in user
      redirect_to root_path, notice: t('.success')
    end

    def destroy
      sign_out
      redirect_to root_path, notice: t('.success')
    end

    private

    def auth
      request.env['omniauth.auth']
    end

    def authenticate_user(auth)
      email = auth[:info][:email].downcase
      nickname = auth[:info][:nickname]
      token = auth[:credentials][:token]
      user = User.find_or_initialize_by(email:)
      user.nickname = nickname
      user.token = token
      user.save!

      user
    end
  end
end
