class RenameSongAlbumArtistName < ActiveRecord::Migration
  def up
    rename_column :songs, :album_arist_name, :album_artist_name
  end

  def down
    rename_column :songs, :album_artist_name, :album_arist_name
  end
end
