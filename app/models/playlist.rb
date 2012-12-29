class Playlist < ActiveRecord::Base
  attr_accessible :title
  has_many :playlist_entries
end
