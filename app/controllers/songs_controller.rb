class SongsController < ApplicationController
  # GET /songs
  # GET /songs.json
  def index
    @songs = Song.find( :all, :order => 'artist_name' ).select

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @songs }
      format.m3u
    end
  end

  def stream
    @songs = Song.find( :all, :order => 'artist_name' )
  end

  def recent
    @songs = Song.where('').order('created_at').reverse_order.limit(20)

    respond_to do |format|
      format.html # recent.html.erb
      format.json { render json: @songs }
    end
  end
  def favorites
    mid_rating = ( Song.maximum("rating") - Song.minimum("rating") ) * 0.4 + Song.minimum("rating")
    @songs = Song.where('rating > ?',mid_rating).order('rating').reverse_order

    respond_to do |format|
      format.html # recent.html.erb
      format.json { render json: @songs }
    end
  end

  # GET /songs/1
  # GET /songs/1.json
  def show
    @song = Song.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @song }
    end
  end

  def calc_recently_uploaded
    @recently_uploaded = Song.where('created_at >= ?',Time.new - 60*60*24).reverse
  end
  before_filter :calc_recently_uploaded, :only => [ :new, :new_placehold, :webcopy ]

  # GET /songs/new
  # GET /songs/new.json
  def new
    @song = Song.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @song }
    end
  end

  # GET /songs/new_placehold
  def new_placehold
    @song = Song.new()
    @song.artist_name = params[:artist_name]
    @song.album_name = params[:album_name]
    @song.artist_name = @song.artist_name # HACK
    @song.album_name = @song.album_name   # HACK
    @song.name = params[:name]
    @song.track = params[:track]
    @song.disk = params[:disk]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @song }
    end
  end

  # GET /songs/1/edit
  def edit
    @song = Song.find(params[:id])
  end

  # POST /songs/1/rate_up
  def rate_up
    @song = Song.find(params[:song_id])
    @song.rate_up
    @song.save!

    respond_to do |format|
      format.json do
        render json: {
          :id => @song.id,
          :rating => @song.rating,
          :min => Song.minimum("rating"),
          :max => Song.maximum("rating"),
        }
      end
    end
  end

  # POST /songs/1/rate_down
  def rate_down
    @song = Song.find(params[:song_id])
    @song.rate_down
    @song.save!

    respond_to do |format|
      format.json do
        render json: {
          :id => @song.id,
          :rating => @song.rating,
          :min => Song.minimum("rating"),
          :max => Song.maximum("rating"),
        }
      end
    end
  end

  def set_tag
    @song = Song.find(params[:song_id])
    key = params[:key]
    value = params[:value]
    @song.tags[key] = value if key and value
    
    respond_to do |format|
      if @song.save
        format.json do
          render json: {
            :id => @song.id,
            :key => key,
            :value => value
          }
        end
        format.html do
          redirect_to @song, notice: "Song tag '#{key}' was set to '#{value}'"
        end
      end
    end
  end

  # POST /songs
  # POST /songs.json
  def create
    @song = Song.new(params[:song])
    @song.artist_name = @song.artist_name # HACK
    @song.album_name = @song.album_name   # HACK

    respond_to do |format|
      if @song.save
        format.html { redirect_to new_song_path, notice: 'Song was successfully created.' }
        format.json { render json: @song, status: :created, location: @song }
      else
        format.html { render action: "new" }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  def webcopy
    @song = Song.new(params[:song])
    @recently_uploaded = Song.where('created_at >= ?',Time.new - 60*60*24).reverse
  end
  def dowebcopy
    url = params[:url]
    puts url.inspect
    Thread.new(url) {|url|
      begin
        require 'uri'

        u = URI.parse("#{[url].flatten.first}")
        puts "Webcopy: #{u}"
        res = Net::HTTP.start( u.host, u.port ) {|http|
          http.request( Net::HTTP::Get.new( u.path ) )
        }
        if "200" == res.code
          song = Song.new()
          song.upload = res.body
          song.original_filename = "#{u}"
          song.save!
        end
      rescue => e
        puts e
        puts e.backtrace
      end
    }
    redirect_to webcopy_songs_path
  end

  # PUT /songs/1
  # PUT /songs/1.json
  def update
    @song = Song.find(params[:id])

    respond_to do |format|
      if @song.update_attributes(params[:song])
        format.html { redirect_to @song, notice: 'Song was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1
  # DELETE /songs/1.json
  def destroy
    @song = Song.find(params[:id])
    @song.destroy

    respond_to do |format|
      format.html { redirect_to songs_url }
      format.json { head :no_content }
    end
  end
end
