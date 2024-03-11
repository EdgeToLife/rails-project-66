class CreateRepositoryWebhookJobStub < ApplicationJob
  def perform(repo_full_name, user_id)
    puts "Webhook created. It really is. Trust me."
  end
end
