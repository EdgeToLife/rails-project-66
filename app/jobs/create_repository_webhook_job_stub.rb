# frozen_string_literal: true

class CreateRepositoryWebhookJobStub < ApplicationJob
  def self.perform_later(repository, _user_id)
    repository.update!(
      name: 'Test',
      language: 'ruby',
      git_url: 'repo_info.git_url',
      ssh_url: 'repo_info.ssh_url',
      full_name: 'repo_info.full_name'
    )
  end
end
