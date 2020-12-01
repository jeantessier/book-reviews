class ChangeNameToAuthor < ActiveRecord::Migration[5.0]
  def change
    rename_column :book_authors, :name, :author
  end
end
