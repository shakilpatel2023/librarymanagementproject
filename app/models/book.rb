class Book < ApplicationRecord
  validates :title, presence: true, length: { in: 3..30 }
  validates :author, presence: true
  validates :ISBN, presence: true, uniqueness: true, length: { is: 13 }
  validates :book_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :transactions, dependent: :destroy

  def self.search(search)
    # Title is for the above case, the OP incorrectly had 'name'
    where("title LIKE ? OR author LIKE ? OR ISBN LIKE ? ", "%#{search}%", "%#{search}%", "%#{search}%")
  end
end
