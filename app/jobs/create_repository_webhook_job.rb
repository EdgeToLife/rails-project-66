# frozen_string_literal: true

class CreateRepositoryWebhookJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(repo_full_name, user_id)
    user = User.find(user_id)
    client = Octokit::Client.new access_token: user.token, auto_paginate: true
    webhook_url = url_for(controller: 'api/checks', action: 'checks', host: ENV.fetch('BASE_URL', nil),
                          only_path: false)
    webhook_options = {
      url: webhook_url,
      content_type: 'json',
      events: ['commit']
    }
    client.create_hook(repo_full_name, 'web', webhook_options)
  rescue StandardError => e
    Rails.logger.debug { "An error occurred: #{e.message}" }
  end
end
