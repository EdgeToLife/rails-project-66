# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  # frozen_string_literal: true
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :repository_analyzer_job, -> { RepositoryAnalyzerJobStub }
    register :create_repository_webhook_job, -> { CreateRepositoryWebhookJobStub }
  else
    register :repository_analyzer_job, -> { RepositoryAnalyzerJob }
    register :create_repository_webhook_job, -> { CreateRepositoryWebhookJob }
  end
end
