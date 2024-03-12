# frozen_string_literal: true

module Web
  class ChecksController < ApplicationController
    before_action :user_authorize

    def show
      @check = Repository::Check.find(params[:id])
      redirect_to repository_path(@check.repository), notice: t('.check_not_completed') unless @check.completed?
    end

    private

    def repository_check_params
      params.require(:check).permit(:id)
    end
  end
end
