module Web
  class RepositoriesController < ApplicationController
    def index
      @repositories = Repository.all
    end

    def new
      @repository = current_user.repositories.build
      client = Octokit::Client.new access_token: current_user.token, auto_paginate: true
      @repos = client.repos
    end

    def create
      @repository = current_user.repositories.new(repository_params)
      @repository.name =
      @repository.language =
      @repository.git_url =
      @repository.ssh_url =
      if @repository.save
        redirect_to repositories_url(@repository), notice: t('.create_success')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    private

    def repository_params
      params.require(:repository).permit(:full_name)
    end
  end
end
