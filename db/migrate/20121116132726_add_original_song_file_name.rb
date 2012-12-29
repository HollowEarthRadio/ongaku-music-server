class AddOriginalSongFileName < ActiveRecord::Migration
  def up
    add_column :songs, :original_filename, :string
  end

  def down
    remove_column :songs, :origional_filename
  end
end
