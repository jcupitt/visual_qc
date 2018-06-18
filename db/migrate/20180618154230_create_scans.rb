class CreateScans < ActiveRecord::Migration[5.1]
  def change
    create_table :scans do |t|
      t.text :subject
      t.text :session

      t.timestamps
    end
  end
end
