# frozen_string_literal: true

module Web
  class ChecksController < ApplicationController
    before_action :user_authorize

    def show
      @check = Repository::Check.find(params[:id])
      redirect_to repository_path(@check.repository), notice: t('.check_not_completed') unless @check.finished?
    end

    def create
      repository = current_user.repositories.find(params[:repository_id])
      check = repository.checks.build
      check.to_in_progress!
      RepositoryAnalyzerJob.perform_later(check, current_user.id)
      redirect_to repository_path(params[:repository_id]), notice: t('.check_started')
    end

    def finished
      @check = Check.find(params[:id])
      @check.finished! if @check.may_finish?
    end

    private

    def repository_check_params
      params.require(:repository).permit(:repository_id, :id)
    end
  end
end
