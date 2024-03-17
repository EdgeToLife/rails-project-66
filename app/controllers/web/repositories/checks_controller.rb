# frozen_string_literal: true

module Web
  module Repositories
    class ChecksController < ApplicationController
      before_action :user_authorize

      def show
        @check = Repository::Check.find(params[:id])
        repository_owner = @check.repository.user
        if current_user == repository_owner
          redirect_to repository_path(@check.repository), notice: t('.check_not_completed') unless @check.finished?
        else
          redirect_to root_path, notice: t('.not_allowed')
        end
      end

      def create
        repository = current_user.repositories.find(params[:repository_id])
        check = repository.checks.build
        repository_analyzer_job = ApplicationContainer[:repository_analyzer_job]
        if check.save
          repository_analyzer_job.perform_later(check)
          redirect_to repository_path(params[:repository_id]), notice: t('.check_started')
        else
          redirect_to repository_path(params[:repository_id], notice: t('.check_not_started'))
        end
      end
    end
  end
end
