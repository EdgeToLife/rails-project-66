# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :octokit, -> { OctokitClientStub }
    register :repository_analyzer_job, -> { RepositoryAnalyzerJobStub }
    register :update_repository_info_and_create_webhook_job, -> { UpdateRepositoryInfoAndCreateWebhookJob }
    # register :update_repository_info_and_create_webhook_job, -> { UpdateRepositoryInfoAndCreateWebhookJobStub }
  else
    register :octokit, -> { Octokit::Client }
    register :repository_analyzer_job, -> { RepositoryAnalyzerJob }
    register :update_repository_info_and_create_webhook_job, -> { UpdateRepositoryInfoAndCreateWebhookJob }
  end
end
