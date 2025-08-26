class CreateKeyTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :key_types do |t|
      t.string :name

      t.timestamps
    end
    add_index :key_types, :name, unique: true
  end
end
