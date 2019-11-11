class CreateBookTitles < ActiveRecord::Migration[5.0]
  def change
    create_table :book_titles do |t|
      t.references :book, foreign_key: true
      t.string :title, null: false
      t.string :link, null: true, limit: 1023
      t.integer :order, null: false, default: 0
    end
  end
end
