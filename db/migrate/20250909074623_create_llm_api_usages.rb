class CreateLlmApiUsages < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_api_usages do |t|
      t.string :email, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end

    add_index :llm_api_usages, :email, unique: true
    add_index :llm_api_usages, :expires_at
  end
end
