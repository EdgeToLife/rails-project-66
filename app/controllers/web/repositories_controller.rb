module Web
  class RepositoriesController < ApplicationController
    include Rails.application.routes.url_helpers
    before_action :user_authorize

    def index
      @repositories = current_user.repositories
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
      repo_full_name = params[:repository][:full_name]
      existing_repository = current_user.repositories.find_by(full_name: repo_full_name)

      if existing_repository
        redirect_to repositories_url, alert: t('.repository_already_added')
      else
        @repository = current_user.repositories.new(repository_params)
        @repository.name = '-'
        @repository.language = nil

        CreateRepositoryWebhookJob.perform_later(repo_full_name, current_user.id)

        if @repository.save
          redirect_to repositories_url, notice: t('.create_success')
        else
          render :new, status: :unprocessable_entity
        end
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
