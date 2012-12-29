class AddTrackToSong < ActiveRecord::Migration
  def up
    add_column :songs, :track, :integer
  end
  def down
    remove_column :songs, :track
  end
end
