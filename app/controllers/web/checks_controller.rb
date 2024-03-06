module Web
  class ChecksController < ApplicationController
    def show
      @check = Repository::Check.find(params[:id])
    end

    private

    def repository_check_params
      params.require(:check).permit(:id)
    end
  end
end
