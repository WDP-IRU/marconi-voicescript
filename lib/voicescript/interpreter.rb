require "liquid"
require "graphlient"

module VoiceScript
  class Client
    def initialize(config)
      @config = config
      @connection = Graphlient::Client.new("https://graphql.contentful.com/content/v1/spaces/#{@config.space_id}",
                                           headers: headers,
                                           http_options: http_options)
    end

    def query(*args)
      @connection.query(*args)
    end

    private

    def http_options
      {
        read_timeout: 20,
        write_timeout: 30,
      }
    end

    def headers
      {
        "Authorization" => "Bearer #{@config.access_token}",
      }
    end
  end

  class Interpreter
    def initialize(config)
      @config = config
    end

    def evaluate(liquid_template, graphql_query)
      parsed_template = Liquid::Template.parse(liquid_template)
      query_client = VoiceScript::Client.new(@config)
      graphql_query_data = VoiceScript::Query.exec(query_client, graphql_query)
      parsed_template.render!(graphql_query_data)
    rescue Liquid::Error => e
      raise VoiceScript::Errors::TemplateError, "Couldn't parse Liquid template (error message: #{e.message})"
    rescue Graphlient::Errors::Error => e
      raise VoiceScript::Errors::GraphQLError, "GraphQL error: (error message: #{e.class} / #{e.message})"
    end
  end
end
