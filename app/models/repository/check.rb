# frozen_string_literal: true

class Repository::Check < ApplicationRecord
  include AASM

  aasm column: 'aasm_state' do
    state :not_started, initial: true
    state :in_progress, :finished, :failed

    event :to_in_progress do
      transitions from: %i[not_started failed], to: :in_progress
    end

    event :finish do
      transitions from: :in_progress, to: :finished
    end

    event :fail do
      transitions from: :in_progress, to: :failed
    end
  end

  belongs_to :repository
end
