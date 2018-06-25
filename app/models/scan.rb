class Scan < ApplicationRecord
  has_many :votes

  def next
    self.class.where("id > ?", id).first
  end

  def previous
    self.class.where("id < ?", id).last
  end
end
