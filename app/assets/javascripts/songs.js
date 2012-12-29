// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//= require jquery_jplayer

$(document).ready(function(){
  $("#jplayer").jPlayer({
    ready: function () {
      $(this).jPlayer("setMedia", {
        mp3: "/media/<%= @song.media_filename  %>",
      });
    },
    swfPath: "/flash/",
    supplied: "mp3"
  });
});

update_rating = function(data) {
  // Update this song's rating number
  $("#song_"+data.id+"_rating_number").text(data.rating)

  img="<img alt=\"*\" height=\"16\" src=\"/assets/star.png\" width=\"16\" />"

  // Update all the song's stars
  $(".song_rating").each(function(i,el){
    number_el = $(el).find(".rating_number")
    rate = parseInt(number_el.text())

    r = ( rate - data.min ) / ( data.max - data.min ) * 5.0
    str = ""
    for( var i = 0; i < Math.floor(r); ++i ) {
      str += img
    }
    $(el).find(".stars").html(str)
  })
}
