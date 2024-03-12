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
      client = Octokit::Client.new access_token: current_user.token, auto_paginate: true
      @repository_list = client.repos.select do |repo|
        language = repo[:language]
        language.present? && Repository.language.values.include?(language.downcase)
      end
    end

    # def check
    #   repository = current_user.repositories.find(params[:id])
    #   check = repository.checks.build
    #   check.to_in_progress!
    #   RepositoryAnalyzerJob.perform_later(check, current_user.id)
    #   flash.now[:notice] = t('.check_started')
    #   redirect_to repository_path(params[:id]), notice: t('.check_started')
    # end

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
          CreateRepositoryWebhookJob.perform_later(repo_full_name, current_user.id)
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
