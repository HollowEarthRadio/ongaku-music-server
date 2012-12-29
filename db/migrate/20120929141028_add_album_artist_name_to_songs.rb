class AddAlbumArtistNameToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :album_arist_name, :string
  end
end
