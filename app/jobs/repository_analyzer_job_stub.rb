# frozen_string_literal: true

class RepositoryAnalyzerJobStub < ApplicationJob
  def self.perform_later(check, _user_id)
    Rails.logger.debug 'OLOLOSH RepositoryAnalyzerJobStub class'
    check = Repository::Check.new(
      repository_id: check.repository_id,
      commit_id: '2b38583',
      data: [],
      aasm_state: 'finished',
      passed: true,
      error_count: 0
    )

    check.save!
  end
end
