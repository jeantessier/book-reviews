class CreateJwtBlacklists < ActiveRecord::Migration[5.0]
  def change
    create_table :jwt_blacklists do |t|
      t.string :jti
    end
    add_index :jwt_blacklists, :jti
  end
end
