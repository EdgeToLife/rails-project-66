# frozen_string_literal: true

module Repositories
  class Repository::Check < ApplicationRecord
    include AASM

    aasm column: 'aasm_state' do
      state :not_started, initial: true
      state :started, :finished, :failed

      event :to_start do
        transitions from: %i[not_started], to: :started
      end

      event :finish do
        transitions from: :started, to: :finished
      end

      event :fail do
        transitions from: :started, to: :failed
      end
    end

    belongs_to :repository
  end
end
