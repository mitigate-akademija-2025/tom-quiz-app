class RemoveApiKeyColumnsFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :openai_api_key, :text
    remove_column :users, :gemini_api_key, :text
  end
end
