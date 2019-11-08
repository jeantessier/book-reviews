class CreateBookYears < ActiveRecord::Migration[5.0]
  def change
    create_table :book_years do |t|
      t.references :book, foreign_key: true
      t.string :year
      t.integer :order
    end
  end
end
