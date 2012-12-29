class AddDiskToSong < ActiveRecord::Migration
  def change
    add_column :songs, :disk, :integer
  end
end
