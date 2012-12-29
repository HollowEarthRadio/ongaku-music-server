class AddSongIDs < ActiveRecord::Migration
  def up
    add_column :songs, :album_id, :integer
    add_column :songs, :artist_id, :integer
  end

  def down
    remove_column :songs, :album_id
    remove_column :songs, :artist_id
  end
end
