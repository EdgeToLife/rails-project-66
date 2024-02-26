class Repository < ApplicationRecord
  include AASM

  aasm column: 'state' do
    state :false, initial: true
    state :in_progress, :completed

    event :to_in_progress do
      transitions from: :false, to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
    end
  end

  belongs_to :user
end
