class Artist < ActiveRecord::Base
  attr_accessible :name
  has_many :songs
  has_many :albums

  def Artist::garbage_collect()
    # Delete all artists that have no songs and no albums
    Artist.all.select {|artist| 
      artist.songs.count == 0 and artist.albums.count == 0
    }.each {|artist|
      puts "[DELETE] Artist:#{artist.name}"
      artist.delete
    }
  end
end
