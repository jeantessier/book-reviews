class CreateBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :books do |t|
      t.string :name, null: false
      t.string :publisher

      t.timestamps
    end
    add_index :books, :name
  end
end
