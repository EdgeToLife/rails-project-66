# frozen_string_literal: true

class CheckMailer < ApplicationMailer
  def check_fail_notification
    @user = params[:user]
    @repository = params[:repository]
    mail(to: @user.email, subject: t('.email_subject_fail'))
  end
end
