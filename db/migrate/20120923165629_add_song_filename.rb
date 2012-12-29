class AddSongFilename < ActiveRecord::Migration
  def up
    add_column :songs, :media_filename, :string
  end

  def down
    remove_column :songs, :media_filename
  end
end
