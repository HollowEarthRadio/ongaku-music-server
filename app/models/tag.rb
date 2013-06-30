class Tag < ActiveRecord::Base
  attr_accessible :key, :song_id, :value
  belongs_to :song
end
