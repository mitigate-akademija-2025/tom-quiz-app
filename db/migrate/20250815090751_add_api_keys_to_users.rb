class AddApiKeysToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :openai_api_key, :text
    add_column :users, :gemini_api_key, :text
  end
end
