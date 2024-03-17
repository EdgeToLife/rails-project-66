# frozen_string_literal: true

module Api
  module Repositories
    class ChecksController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        payload = JSON.parse(request.body.read)
        repo_id = payload['repository']['id']
        repository = Repository.find_by(github_id: repo_id)

        if repository.nil?
          render json: { error: 'Repository not found' }, status: :not_found
          return
        end

        check = repository.checks.build
        repository_analyzer_job = ApplicationContainer[:repository_analyzer_job]
        repository_analyzer_job.perform_later(check, repository.user.id)

        head :ok
      end
    end
  end
end
