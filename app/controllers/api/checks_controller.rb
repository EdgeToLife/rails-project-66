# frozen_string_literal: true

module Api
  class ChecksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      payload = JSON.parse(request.body.read)
      repo_id = payload['repository']['id']
      repository = Repository.find_by(github_id: repo_id)

      return if repository.nil?

      check = repository.checks.build

      RepositoryAnalyzerJob.perform_later(check) if check.save!

      head :ok
    end
  end
end
