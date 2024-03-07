# frozen_string_literal: true

class CheckMailer < ApplicationMailer
  def check_fail_notification
    @user = params[:user]
    @repo_full_name = params[:repository]
    mail(to: @user.email, subject: t('email_subject_fail'))
  end
end
