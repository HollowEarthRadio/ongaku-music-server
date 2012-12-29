class PlaylistEntriesController < ApplicationController
  # POST /playlist_entries
  def create
    @playlist_entry = PlaylistEntry.new({
      :song_id => params[:song_id],
      :playlist_id => params[:playlist_id]
    })
    @playlist_entry.save

    redirect_to Playlist.find(params[:playlist_id])
  end

  # DELETE /playlist_entries
  def destroy
    @playlist_entry = PlaylistEntry.find(params[:id])
    @playlist_entry.destroy

    respond_to do |format|
      format.html { redirect_to playlist_url }
    end
  end
end
