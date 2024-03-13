# frozen_string_literal: true

class CreateRepositoryWebhookJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(repository, user_id)
    user = User.find(user_id)
    client = Octokit::Client.new access_token: user.token, auto_paginate: true
    repo_full_name = update_repository_info(repository, client)

    webhook_url = url_for(controller: 'api/checks',
                          action: 'checks',
                          host: ENV.fetch('BASE_URL', nil),
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

  private

  def update_repository_info(repository, client)
    repo_info = client.repository(repository.github_id)
    repository.update!(
      name: repo_info.name,
      language: repo_info.language.downcase,
      git_url: repo_info.git_url,
      ssh_url: repo_info.ssh_url,
      full_name: repo_info.full_name
    )
    repo_info.full_name
  end
end
