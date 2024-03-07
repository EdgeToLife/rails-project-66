# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/check_mailer
class CheckMailerPreview < ActionMailer::Preview
  def check_fail_notification
    CheckMailer.with(user: User.last, repository: Repository.last.full_name).check_fail_notification
  end
end
