module VoiceScript

  class Query
    def self.exec(client, query)
      response = client.query(query)
      response.original_hash["data"]
    end
  end

end