require 'active_support/inflector'
require 'active_support/core_ext/object/to_query'
require 'gli'
require 'json'
require 'logger'
require "targetprocess/version"
require 'terminal-table'


module Targetprocess
  class Config
    class << self
      def base_uri
        ENV.fetch('targetprocess_base_uri')
      end

      def logger
        @logger ||= ::Logger.new(STDOUT)
      end

      def password
        ENV.fetch('targetprocess_password')
      end

      def per_page
        ENV.fetch('targetprocess_per_page', 25)
      end

      def username
        ENV.fetch('targetprocess_username')
      end
    end
  end

  class CLI
    extend GLI::App

    program_desc 'Targetprocess CLI'

    version Targetprocess::VERSION

    subcommand_option_handling :normal
    arguments :strict

    desc 'List stories'
    command :stories do |c|
      c.flag :state, desc: 'State'
      c.flag :page, desc: 'Page', default_value: 1, type: Integer
      c.flag :per, desc: 'Per page', default_value: Config.per_page, type: Integer

      c.action do |_global, opts, _args|
        params = { format: :json }

        params[:take] = opts[:per]
        params[:skip] = params[:take] * (opts[:page] - 1)
        params[:where] = Filter::State.new(opts[:state]) if opts[:state]

        puts Terminal::Table.new(
          headings: %w(Id Name Owner State),
          rows: UserStory.all(params).map(&:to_a),
        )
      end
    end
  end

  module Filter
    class State
      attr_reader :name

      def initialize(name = 'In Progress')
        @name = name
      end

      def to_s
        "EntityState.name eq '#{name}'"
      end
    end
  end

  class UserStory
    class ErrorResponse < ArgumentError
      def initialize(code, msg)
        super([code, msg].join("\n"))
      end
    end

    class << self
      def all(opts = {})
        query = { format: :json }.merge(opts)

        get('UserStories', query)['Items'].map { |data| new(data) }
      end

      def get(path, params)
        query = params.to_query
        uri = URI.join(Config.base_uri, path)
        uri.query = query
        Config.logger.info uri.to_s

        req = Net::HTTP::Get.new(uri)
        req.basic_auth(Config.username, Config.password)

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(req)
        end

        if res.is_a?(Net::HTTPSuccess)
          JSON.parse(res.body)
        else
          raise ErrorResponse.new(res.code, res.body)
        end
      end
    end

    attr_reader :id, :name, :owner, :state

    def initialize(attrs = {})
      @id = attrs['Id']
      @name = attrs['Name']
      @owner = attrs['Owner']['Login']
      @state = attrs['EntityState']['Name']
    end

    def to_a
      [id, name, owner, state]
    end
  end
end
