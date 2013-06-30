class Album < ActiveRecord::Base
  attr_accessible :title
  attr_accessible :artist, :artist_id, :artist_name
  has_many :songs
  belongs_to :artist

  def artist_name()
    if self.artist
      self.artist.name
    else
      nil
    end
  end
  def artist_name=( name )
    self.artist = Artist.where( "name = ?", name ).first
  end
  def Album::garbage_collect()
    # Delete all albums that have no songs.  Note: this will grab albums that were manually created and have no placeholders
    Album.all.select {|album|
      album.songs.count == 0
    }.each {|album|
      puts "[DELETE] Album:#{ album.artist ? "#{album.artist.name} -" : "" }#{album.title}"
      album.delete
    }
  end
#  def artist=(name)
#    a = Artist.where( "name = ?", name )
#    if( a )
#      self.artist = a
#    end
#  end
end
