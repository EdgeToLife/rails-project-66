# frozen_string_literal: true

class Repository < ApplicationRecord
  extend Enumerize

  belongs_to :user
  has_many :checks, class_name: 'Repository::Check', dependent: :destroy
  enumerize :language, in: %i[javascript ruby], default: nil, allow_nil: true

  validates :github_id, presence: true
end
