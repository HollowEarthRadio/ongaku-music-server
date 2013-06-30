class Song < ActiveRecord::Base
  attr_accessible :upload
  attr_accessible :album, :album_name
  attr_accessible :artist, :artist_name, :album_artist_name
  attr_accessible :name, :media_filename
  attr_accessible :track, :disk
  attr_accessible :origional_filename
  attr_accessible :license
  belongs_to :artist
  belongs_to :album

  class TagProxy
    def initialize( song )
      @song = song
      @tag_cache = {}
      @dirty = {}
    end

    include Enumerable
    def each()
      Tag.where( :song_id => @song.id ).each {|tag|
        yield( tag.key, tag.value )
      }
    end

    def []( key )
      return @tag_cache[key] if @tag_cache.include?( key )

      @tag_cache[key] = Tag.where( :song_id => @song.id, :key => key ).first.value
    end
    def []=( key, value )
      @dirty[key] = true if @tag_cache[key] != value
      @tag_cache[key] = value

      @song.on_save {
        self.save!
      }
    end

    def save!()
      @dirty.each {|k,v|
        if( v == true )
          tag = Tag.where( :song_id => @song.id, :key => k ).first
          if !tag
            tag = Tag.new
            tag.song_id = @song.id
            tag.key = k
          end
          tag.value = @tag_cache[k]
          if tag.save!
            @dirty[k] = false
          end
        end
      }
    end

  end

  def tags()
    @tags_proxy ||= TagProxy.new(self)
  end

  def Song.minimum_rating()
    @@minimum_rating ||= Song.minimum("rating")
  end
  def Song.maximum_rating()
    @@maximum_rating ||= Song.maximum("rating")
  end
  def rating_percent()
    ( ( self.rating || 0 ).to_i - Song.minimum_rating ).to_f / ( Song.maximum_rating - Song.minimum_rating )
  end

  def artist_name=( artist_name )
    # Make sure leading and trailing whitespace doesn't create multiple copies of an artist
    artist_name ||= ""
    artist_name.gsub!(/^ */,'')
    artist_name.gsub!(/ *$/,'')

    # Make sure the ActiveRecord gets the artist name
    super

    # Update underlying field
    self.push_tags

    if !( ["",nil].include?( artist_name ) )
      # Perform a lookup in the artists to try and find an existing artist
      # with the name given
      artists = Artist.where( "name = ?", artist_name )

      # If there was no artist
      if( artists.size == 0 )
        # Go ahead and create one now
        artist = Artist.new({"name" => artist_name })
        @artist = artist
        self.on_save { @artist.save! }
      else
        # otherwise, use the first artist returned
        artist = artists[0]
      end

      # Update the artist field
      self.artist = artist

    end

    # Check to see if there is an album assigned to this artist
    if !self.album and self.album_name
      # Refresh the album name assignment
      self.album_name = self.album_name    
    end
  end
  def artist_name()
    if( self.artist )
      self.artist.name
    else
      super
    end
  end

  def album_name=( album_name )
    # Make sure leading and trailing whitespace doesn't create multiple copies of an album
    album_name ||= ""
    album_name.gsub!(/^ */,'')
    album_name.gsub!(/ *$/,'')

    # Make sure the ActiveRecord gets the album name
    super

    if( album_name == "" or !album_name )
      self.album = nil
      return
    end

    # Determine what to use for the album artist
    album_artist_name = self.album_artist_name || self.artist_name

    # Try to find the album artist
    album_artists = Artist.where( :name => album_artist_name )
    if( album_artists.size == 0 ) 
      # Create one if it does not exist
      album_artist = Artist.new( :name => album_artist_name )
      @album_artist = album_artist
      self.on_save { @album_artist.save! }
    else
      # Use the first entry if it does exist
      album_artist = album_artists[0]
    end

    # Try to find the album
    albums = Album.where( :title => album_name, :artist_id => album_artist )
    if( albums.size == 0 )
      album = Album.new({"title"=> album_name, "artist" => album_artist})
      @album = album
      self.on_save {|song| @album.save! }
    else
      album = albums[0]
    end

    # Update the album field
    self.album = album

    # Update underlying field
    self.push_tags
  end
  def album_name()
    if self.album
      self.album.title
    else
      super
    end
  end

  def media_path()
    File.join(Rails.root,"public","media",self.media_filename)
  end

  def upload=( upload )
    require 'taglib'

    # Get the extension of the uploaded file
    ext = File.extname( upload.original_filename )

    # Preserve the origional filename for later use in tagging
    self.original_filename = upload.original_filename

    # Generate a filename to store the media at
    random_filename = (0..32).map{ ('a'..'z').to_a[rand(26)] }.join + ext
    self.media_filename = random_filename

    # Write the media to disk
    File.open( media_path, "wb" ) {|f|
      f.write( upload.read )
    }

    # Extract tags
    self.pull_tags
  end

  def pull_tags()
    require 'taglib'

    # Extract tags from mp3 file
    TagLib::MPEG::File.open(media_path) do |fr|
      tag = fr.id3v2_tag

      # Capture the song title
      self.name = tag.title.chomp if tag.title

      # Capture the album artist name
      if frame = tag.frame_list('TPE2').first
        self.album_artist_name = frame.to_string
      end

      # Capture the disk number
      if frame = tag.frame_list('TPOS').first
        self.disk = frame.to_string.to_i
      end

      # Capture the song artist
      self.artist_name = tag.artist.chomp if tag.artist

      # Capture the album name
      self.album_name = tag.album.chomp if tag.album

      self.track = tag.track if tag.track
    end
  end
  def push_tags()
    return if !has_media?

    require 'taglib'

    # Store tags in MP3 file
    TagLib::MPEG::File.open(media_path) do |fr|
      tag = fr.id3v2_tag

      tag.title = self.name if self.name
      tag.artist = self.artist_name if self.artist_name
      tag.album = self.album_name if self.album_name
      tag.track = self.track  if self.track

      fr.save
    end
  end

  def id3_tags()
    return [] if !has_media?

    require 'taglib'

    res = []
    TagLib::MPEG::File.open( media_path ) do |fr|
      tag = fr.id3v2_tag
      tag.frame_list.each {|frame|
        res << [ frame.frame_id, frame.to_string ]
      }
    end

    return res
  end

  def has_media?()
    return self.media_filename && self.media_filename != ""
  end
  def destroy()
    super

    # Remove the file if it exists still
    if has_media?
      path = File.join(Rails.root,"public","media",self.media_filename)
      File.delete( path ) if File.exist?( path )
    end

    return true
  end

  def rate_up()
    self.rating = ( self.rating || 0 ) + 1
  end
  def rate_down()
    self.rating = ( self.rating || 0 ) - 1
  end

  def save!()
    super
    @save_handlers.each {|block| block.call }
  end
  def save()
    super
    @save_handlers.each {|block| block.call }
  end
  def on_save( &block )
    @save_handlers ||= []
    @save_handlers.push(block)
  end
end
