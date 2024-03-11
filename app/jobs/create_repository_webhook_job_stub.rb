class CreateRepositoryWebhookJobStub < ApplicationJob
  def perform(_repo_full_name, _user_id)
    puts 'Webhook created. It really is. Trust me.'
  end
end
