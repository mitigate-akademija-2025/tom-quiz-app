class AddOauthFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :name, :string

    # Make password optional for OAuth users
    change_column_null :users, :password_digest, true

    # Add composite unique index for OAuth users
    add_index :users, [ :provider, :uid ], unique: true

    # Add index for faster lookups
    add_index :users, :provider
  end
end
