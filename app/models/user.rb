class User < ApplicationRecord
  has_many :repositories
  validates :email, presence: true
end
