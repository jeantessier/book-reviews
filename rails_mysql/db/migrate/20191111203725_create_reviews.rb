class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
      t.references :reviewer, foreign_key: { to_table: :users }
      t.references :book, foreign_key: true
      t.text :body, null: false
      t.date :start
      t.date :stop

      t.timestamps
    end
  end
end
