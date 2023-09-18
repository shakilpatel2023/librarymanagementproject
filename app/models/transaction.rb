class Transaction < ApplicationRecord
  belongs_to :patron
  belongs_to :book
  def self.search(search)
    joins(:patron, :book)
      .where("transactions.date LIKE ? OR transactions.return_date LIKE ? OR transaction.late_fee LIKE ? OR " \
             "patrons.name LIKE ? OR patrons.contact_information LIKE ? OR " \
             "books.title LIKE ? OR books.author LIKE ? OR books.ISBN LIKE ?",
             "%#{search}%", "%#{search}%",
             "%#{search}%", "%#{search}%",
             "%#{search}%", "%#{search}%", "%#{search}%")
  end
end
