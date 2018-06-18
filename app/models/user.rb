class User < ApplicationRecord
  validates :name, length: { minimum: 5, maximum: 20 }, presence: true

  has_many :votes
end
