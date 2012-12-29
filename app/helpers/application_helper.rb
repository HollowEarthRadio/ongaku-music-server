module ApplicationHelper
  def jplayer_play_index( index )
    output = ActiveSupport::SafeBuffer.new
    output.safe_concat("<a href='#song_")
    output << index.to_s
    output.safe_concat("' onclick='mp.play_song(")
    output << index.to_s
    output.safe_concat(")'>Play</a>")
  end

  def song_artist_link( song )
    if song.artist
      link_to song.artist.name, song.artist
    else
      link_to ( ["",nil].include?( song.artist_name ) ? "[untitled]" : song.artist_name ),
        :controller => "artists", :action => "new",
        :name => song.artist_name,
        :song_update => song
    end
  end
  def song_album_link( song )
    if song.album
      link_to ( song.album.title ), 
        song.album
    else
      link_to ( ["",nil].include?(song.album_name) ? "[untitled]" : song.album_name ),
        :controller => "albums", :action => "new",
        :title => song.album_name,
        :artist => song.artist || song.artist_name,
        :song_update => song
    end
  end

  def nav_items()
    ActionController::Base.view_paths.to_a.reverse.map {|path|
      Dir.glob( File.join( path, "*", "_nav_top_heading.html.erb" ) ).sort
    }.flatten.map {|item|
      item.gsub(/^.*app\/views\//,'').gsub("_nav_top_heading.html.erb","nav_top_heading")
    }
  end
end
