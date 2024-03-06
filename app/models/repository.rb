class Repository < ApplicationRecord
  extend Enumerize

  belongs_to :user
  has_many :checks, class_name: 'Repository::Check', dependent: :destroy
  enumerize :language, in: [:javascript, :ruby], default: nil, allow_nil: true
end
