class AddLicenseToSong < ActiveRecord::Migration
  def change
    add_column :songs, :license, :string
  end
end
