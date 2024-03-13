# frozen_string_literal: true

module Web
  class RepositoriesController < ApplicationController
    include Rails.application.routes.url_helpers
    before_action :user_authorize

    def index
      @repositories = current_user.repositories
    end

    def show
      @repository = current_user.repositories.find(params[:id])
    end

    def new
      @new_repository = current_user.repositories.build
      octokit = ApplicationContainer[:octokit]
      client = octokit.new(access_token: current_user.token, auto_paginate: true)
      # client = Octokit::Client.new access_token: current_user.token, auto_paginate: true
      @repository_list = client.repos.select do |repo|
        language = repo[:language]
        language.present? && Repository.language.values.include?(language.downcase)
      end
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

        if @repository.save
          create_repository_webhook_job = ApplicationJob[:create_repository_webhook_job]
          create_repository_webhook_job.perform_later(repo_full_name, current_user.id)
          # CreateRepositoryWebhookJob.perform_later(repo_full_name, current_user.id)
          redirect_to repositories_url, notice: t('.create_success')
        else
          render :new, status: :unprocessable_entity
        end
      end
    end

    private

    def repository_params
      params.require(:repository).permit(:full_name)
    end
  end
end
