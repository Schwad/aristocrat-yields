class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.string :symbol
      t.float :idealness

      t.timestamps null: false
    end
  end
end
