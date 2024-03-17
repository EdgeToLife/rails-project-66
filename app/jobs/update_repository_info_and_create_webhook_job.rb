# frozen_string_literal: true

class UpdateRepositoryInfoAndCreateWebhookJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(repository)
    user = repository.user
    client = Octokit::Client.new access_token: user.token, auto_paginate: true
    update_repository_info(repository, client)
    repo_full_name = repository.full_name

    webhook_url = api_checks_url(host: ENV.fetch('BASE_URL', nil), only_path: false)
    webhook_options = {
      url: webhook_url,
      content_type: 'json',
      events: ['commit']
    }

    exist_hook_urls = client.hooks(repo_full_name).map { |hook| hook[:config][:url] }
    client.create_hook(repo_full_name, 'web', webhook_options) unless exist_hook_urls.include?(webhook_url)
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
  end
end
