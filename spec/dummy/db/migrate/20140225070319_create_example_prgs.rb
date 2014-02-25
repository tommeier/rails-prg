class CreateExamplePrgs < ActiveRecord::Migration
  def change
    create_table :example_prgs do |t|
      t.text :subject
      t.text :body
      t.boolean :published

      t.timestamps
    end
    add_index :example_prgs, :subject, unique: true
  end
end
