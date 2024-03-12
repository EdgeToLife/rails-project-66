# frozen_string_literal: true

class RepositoryAnalyzerJobStub < ApplicationJob
  def self.perform(check, _user_id)
    check = Repository::Check.new(
      repository_id: check.repository_id,
      commit_id: '2b38583',
      data: [],
      aasm_state: 'completed',
      passed: true,
      error_count: 0
    )

    check.save!
  end
end
