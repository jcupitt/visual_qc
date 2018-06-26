class User < ApplicationRecord
  has_many :votes, dependent: :destroy

  validates :name, length: { minimum: 5, maximum: 20 }, presence: true

end
