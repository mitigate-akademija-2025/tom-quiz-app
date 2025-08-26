class CreateApiKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :api_keys do |t|
      t.references :user, null: false, foreign_key: true
      t.references :key_type, null: false, foreign_key: true
      t.text :key

      t.timestamps
    end
  end
end
