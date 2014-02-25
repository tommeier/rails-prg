class CreateErrorDuplicators < ActiveRecord::Migration
  def change
    create_table :error_duplicators do |t|
      t.text :subject
      t.text :body
      t.boolean :published

      t.timestamps
    end
    add_index :error_duplicators, :subject, unique: true
  end
end
