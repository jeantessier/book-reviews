class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
      t.references :reviewer, foreign_key: {to_table: :users, on_delete: :cascade}
      t.references :book, foreign_key: {to_table: :books, on_delete: :cascade}
      t.text :body, null: false
      t.date :start
      t.date :stop

      t.timestamps
    end
  end
end
