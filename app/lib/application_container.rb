# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :octokit, -> { OctokitClientStub }
    register :repository_analyzer_job, -> { RepositoryAnalyzerJobStub }
    register :create_repository_webhook_job, -> { CreateRepositoryWebhookJobStub }
  else
    register :octokit, -> { Octokit::Client }
    register :repository_analyzer_job, -> { RepositoryAnalyzerJob }
    register :create_repository_webhook_job, -> { CreateRepositoryWebhookJob }
  end
end
