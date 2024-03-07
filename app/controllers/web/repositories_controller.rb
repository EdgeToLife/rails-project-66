module Web
  class RepositoriesController < ApplicationController
    include Rails.application.routes.url_helpers
    def index
      # @repositories = Repository.includes('checks').all
      @repositories = Repository.joins(:checks)
                                .select('repositories.*, repository_checks.error_count AS last_error_count')
                                .order('repository_checks.created_at DESC')
    end

    def new
      @new_repository = current_user.repositories.build
      client = Octokit::Client.new access_token: current_user.token, auto_paginate: true
      @repository_list = client.repos
    end

    def check
      repository = Repository.find(params[:id])
      check = repository.checks.build()
      check.to_in_progress!
      RepositoryAnalyzerJob.perform_later(check, current_user.id)
      redirect_to repository_path(params[:id]), notice: t('.check_started')
    end

    def create
      @repository = current_user.repositories.new(repository_params)
      @repository.name = '-'
      @repository.language = nil

      repo_full_name = params[:repository][:full_name]

      CreateRepositoryWebhookJob.perform_later(repo_full_name, current_user.id, form_authenticity_token)

      if @repository.save
        redirect_to repositories_url, notice: t('.create_success')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @repository = Repository.find(params[:id])
    end

    def completed
      @check = Check.find(params[:id])
      @check.completed! if @check.may_complete?
    end

    private

    def repository_params
      params.require(:repository).permit(:full_name, :name, :language, :check_id)
    end
  end
end
