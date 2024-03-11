module Web
  class ChecksController < ApplicationController
    before_action :user_authorize

    def show
      @check = Repository::Check.find(params[:id])
      unless @check.completed?
        redirect_to repository_path(@check.repository), notice: t('.check_not_completed')
      end
    end

    private

    def repository_check_params
      params.require(:check).permit(:id)
    end
  end
end
