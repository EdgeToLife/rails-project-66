# frozen_string_literal: true

module Api
  class ChecksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def checks
      payload = JSON.parse(request.body.read)
      repo_id = payload['repository']['id']
      repository = Repository.find_by(github_id: repo_id)
      check = repository.checks.build
      check.to_in_progress!
      repository_analyzer_job = ApplicationContainer[:repository_analyzer_job]
      repository_analyzer_job.perform_later(check, repository.user.id)

      head :ok
    end
  end
end
