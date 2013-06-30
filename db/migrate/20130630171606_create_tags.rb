class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :song_id
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
