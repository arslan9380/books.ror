class AddAutheticationTokenToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :authentication_token, :string
  end
end
