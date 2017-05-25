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

    MINIMUM_TAKE = 1
    MAXIMUM_TAKE = 1000

    class << self
      # http://joshfrankel.me/blog/2015/how-to/restrict-an-integer-to-a-specific-range-in-ruby/
      def clamp(value, min, max)
        [value, min, max].sort[1]
      end
    end

    program_desc 'Targetprocess CLI'

    version Targetprocess::VERSION

    subcommand_option_handling :normal
    arguments :strict

    desc 'Manage projects'
    command :projects do |c|
      c.flag :page, desc: 'Page', default_value: 1, type: Integer
      c.flag :per, desc: 'Per page', default_value: Config.per_page, type: Integer

      c.action do |_global, opts, _args|
        params = { where: "EntityType.name eq 'Project'" }
        params[:take] = clamp(opts[:per], MINIMUM_TAKE, MAXIMUM_TAKE)
        params[:skip] = params[:take] * (opts[:page] - 1)

        rows = General.all(params).map(&:to_a)

        puts Terminal::Table.new(
          headings: %w(Id Name Owner),
          rows: rows,
        )
        puts "Showing #{rows.size} records"
      end
    end

    desc 'Manage stories'
    command :stories do |c|
      c.flag :developer, desc: 'Developer'
      c.flag :owner, desc: 'Story owner login'
      c.flag :page, desc: 'Page', default_value: 1, type: Integer
      c.flag :per, desc: 'Per page', default_value: Config.per_page, type: Integer
      c.flag :sprint, desc: 'Sprint (Team Iteration)'
      c.flag :state, desc: 'State'

      c.default_desc 'List stories'
      c.action do |_global, opts, _args|
        params = {}

        params[:take] = clamp(opts[:per], MINIMUM_TAKE, MAXIMUM_TAKE)
        params[:skip] = params[:take] * (opts[:page] - 1)

        filters = []
        filters << Filter::State.new(opts[:state]) if opts[:state]
        filters << Filter::Owner.new(opts[:owner]) if opts[:owner]
        filters << Filter::Developer.new(opts[:developer]) if opts[:developer]
        filters << Filter::Sprint.new(opts[:sprint]) if opts[:sprint]

        params[:where] = Filter.and(filters)
        params[:orderBy] = 'EntityState.Name'

        rows = UserStory.all(params).map(&:to_a).each do |story|
          if opts[:developer]
            story << opts[:developer]
          end

          if opts[:sprint]
            story << opts[:sprint]
          end
        end

        headings = %w(Id Name Owner State)
        headings << 'Developer' if opts[:developer]
        headings << 'Sprint' if opts[:sprint]

        puts Terminal::Table.new(
          headings: headings,
          rows: rows,
        )
        puts "Showing #{rows.size} records"
      end

      c.command :create do |d|
        d.flag :name, desc: 'Name of the story', required: true
        d.flag :project, desc: 'Project Id', type: Integer, required: true

        d.action do |_global, opts, _args|
          params = {
            name: opts[:name],
            project: {
              id: opts[:project],
            },
          }

          story = UserStory.create(params)

          puts Terminal::Table.new(
            headings: %w(Id Name Owner State),
            rows: [story.to_a],
          )
        end
      end
    end
  end

  module Filter
    def self.and(filters)
      filters.compact.map { |x| "(#{x})" }.join('and')
    end

    class Developer
      attr_reader :login

      def initialize(login)
        @login = login
      end

      def to_s
        "AssignedUser.Login eq '#{login}'"
      end
    end

    class Owner
      attr_reader :login

      def initialize(login)
        @login = login
      end

      def to_s
        "Owner.Login eq '#{login}'"
      end
    end

    class Sprint
      attr_reader :number

      def initialize(number)
        @number = number
      end

      def to_s
        "TeamIteration.Name eq 'Sprint ##{number}'"
      end
    end

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

  class API
    class ErrorResponse < ArgumentError
      def initialize(code, msg)
        super([code, msg].join("\n"))
      end
    end

    def get(path, params)
      query = { format: :json }.merge(params).to_query
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

    def post(path, params, body)
      uri = URI.join(Config.base_uri, path)
      uri.query = { format: :json }.merge(params).to_query
      Config.logger.info uri.to_s
      Config.logger.info body

      headers = { 'Content-Type' => 'application/json' }
      req = Net::HTTP::Post.new(uri, headers)
      req.body = body
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

  class General
    class << self
      def all(opts = {})
        API.new.get('Generals', opts)['Items'].map { |data| new(data) }
      end
    end

    attr_reader :id, :name, :owner

    def initialize(attrs = {})
      @id = attrs['Id']
      @name = attrs['Name']
      @owner = attrs['Owner']['Login']
    end

    def to_a
      [id, name, owner]
    end
  end

  class UserStory
    class << self
      def all(opts = {})
        API.new.get('UserStories', opts)['Items'].map { |data| new(data) }
      end

      def create(params)
        body = params.to_json
        res = API.new.post('UserStories', {}, body)

        new(res)
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
