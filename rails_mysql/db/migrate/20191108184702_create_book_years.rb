class CreateBookYears < ActiveRecord::Migration[5.0]
  def change
    create_table :book_years do |t|
      t.references :book, foreign_key: true
      t.string :year, null: false
      t.integer :order, null: false, default: 0
    end
  end
end
