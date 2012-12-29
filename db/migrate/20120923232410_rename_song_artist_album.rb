class RenameSongArtistAlbum < ActiveRecord::Migration
  def up
    rename_column :songs, :artist, :artist_name
    rename_column :songs, :album, :album_name
  end

  def down
    rename_column :songs, :artist_name, :artist
    rename_column :songs, :album_name, :album
  end
end
