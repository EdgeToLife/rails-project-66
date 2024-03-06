class Api::ChecksController < ApplicationController
  def verified_request?
    true
  end

  def checks
    payload = JSON.parse(request.body.read)
    repo_full_name = payload["repository"]["full_name"]
    repository = Repository.find_by(full_name: repo_full_name)
    check = repository.checks.build()
    check.to_in_progress!

    RepositoryAnalyzerJob.perform_later(check, repository.user.id)
    debugger
    head :ok
  end
end
