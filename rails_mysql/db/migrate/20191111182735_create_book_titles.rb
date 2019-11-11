class CreateBookTitles < ActiveRecord::Migration[5.0]
  def change
    create_table :book_titles do |t|
      t.references :book, foreign_key: true
      t.string :title
      t.string :link
      t.integer :order
    end
  end
end
