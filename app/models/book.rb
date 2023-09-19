class Book < ApplicationRecord
  validates :title, presence: true, uniqueness: true #, length: { in: 3..30 }
  validates :author, presence: true
  validates :ISBN, presence: true, uniqueness: true #, length: { is: 13 }
  validates :book_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :transactions, dependent: :destroy
  # has_one_attached :image

  def self.search(search)
    where("title LIKE ? OR author LIKE ? OR ISBN LIKE ? ", "%#{search}%", "%#{search}%", "%#{search}%")
  end
end
