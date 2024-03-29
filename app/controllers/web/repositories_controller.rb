# frozen_string_literal: true

module Web
  class RepositoriesController < ApplicationController
    before_action :user_authorize

    def index
      @repositories = current_user.repositories
    end

    def show
      @repository = current_user.repositories.find(params[:id])
      @checks = @repository.checks.order(created_at: :desc)
    end

    def new
      @new_repository = current_user.repositories.build
      octokit = ApplicationContainer[:octokit]
      client = octokit.new(access_token: current_user.token, auto_paginate: true)
      @repository_list = client.repos.select do |repo|
        language = repo[:language]
        language.present? && Repository.language.value?(language.downcase)
      end
    end

    def create
      github_id = params[:repository][:github_id]

      existing_repository = current_user.repositories.find_by(github_id:)

      if existing_repository
        redirect_to repositories_url, alert: t('.repository_already_added')
      else
        @repository = current_user.repositories.new(repository_params)

        if @repository.save
          UpdateRepositoryInfoAndCreateWebhookJob.perform_later(@repository)
          redirect_to repositories_url, notice: t('.create_success')
        else
          redirect_to new_repository_path, alert: t('.repository_required')
        end
      end
    end

    private

    def repository_params
      params.require(:repository).permit(:github_id)
    end
  end
end
