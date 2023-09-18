class Patron < ApplicationRecord
  validates :name, presence: true, length: { in: 3..30 }
  validates :contact_information, presence: true, uniqueness: true, numericality: true, length: { is: 10 }
  has_many :transactions, dependent: :destroy
  def self.search(search)
    where("name LIKE ? OR contact_information LIKE ? ", "%#{search}%", "%#{search}%")
  end
end
