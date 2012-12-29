module SongsHelper
  def rating( song )
    rate = ( song.rating || 0 ).to_i
    r = ( rate - Song.minimum("rating") ).to_f / ( Song.maximum("rating") - Song.minimum("rating") ) * 5.0
    
    o = ""
    o << "<div id='song_#{song.id}_rating' class='song_rating'>"
    o << "<span class='stars'>"
    r.to_i.times do
      o << image_tag("star.png", :alt => "*", :size => "16x16")
    end
    o << "</span>"
    o << "(<span id='song_#{song.id}_rating_number' class='rating_number'>#{rate}</span>)"
    o << "</div>"
    return raw(o)
  end
  def rate_up( song )
    o = ""
    o << "<a onclick='$.ajax({"
    o <<   "url:\"#{song_rate_up_path(song, :format => :json)}\","
    o <<   "type: \"POST\","
    o <<   "success: update_rating,"
    o << "});return false;'>"
    o << image_tag("rate_up.png", :alt => "+", :size => "16x16")
    o << "</a>"
    return raw(o)
  end
  def rate_down( song )
    o = ""
    o << "<a onclick='$.ajax({"
    o <<   "url:\"#{song_rate_down_path(song, :format => :json)}\","
    o <<   "type: \"POST\","
    o <<   "success: update_rating,"
    o << "});return false;'>"
    o << image_tag("rate_down.png", :alt => "-", :size => "16x16")
    o << "</a>"
    return raw(o)
  end
end
