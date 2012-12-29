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
#  def artist=(name)
#    a = Artist.where( "name = ?", name )
#    if( a )
#      self.artist = a
#    end
#  end
end
