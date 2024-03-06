class Repository::Check < ApplicationRecord
  include AASM

  aasm column: 'state' do
    state :not_started, initial: true
    state :in_progress, :completed, :failed

    event :to_in_progress do
      transitions from: %i[not_started failed], to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
    end

    event :fail do
      transitions from: :in_progress, to: :failed
    end
  end

  belongs_to :repository, class_name: 'Repository'
end
