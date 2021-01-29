module VoiceScript 

  class Config < Struct.new(:access_token, :space_id, keyword_init: true)
  end

end