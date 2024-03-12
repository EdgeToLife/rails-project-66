# frozen_string_literal: true

class CreateRepositoryWebhookJobStub < ApplicationJob
  def perform(_repo_full_name, _user_id)
    puts 'OLOLOSH CreateRepositoryWebhookJobStub class'
    Rails.logger.debug 'Webhook created. It really is. Trust me.'
  end
end
