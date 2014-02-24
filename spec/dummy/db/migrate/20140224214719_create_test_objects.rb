class CreateTestObjects < ActiveRecord::Migration
  def change
    create_table :test_objects do |t|
      t.text :subject
      t.text :body
      t.boolean :published

      t.timestamps
    end
    add_index :test_objects, :subject, unique: true
  end
end
