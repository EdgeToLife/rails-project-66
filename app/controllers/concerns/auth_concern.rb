# frozen_string_literal: true

module AuthConcern
  extend ActiveSupport::Concern

  included do
    helper_method :user_signed_in?, :current_user
  end

  def user_authorize
    if user_signed_in?
      true
    else
      user_not_authorized
    end
  end

  def user_signed_in?
    !!current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out
    session.delete(:user_id)
    # session.clear
  end

  private

  def user_not_authorized
    flash[:alert] = t('.not_allowed')
    redirect_back(fallback_location: root_path)
  end
end
