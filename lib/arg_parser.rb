require 'optparse'
require 'optparse/time'
require 'ostruct'

class ArgParserConfiguration
  class ScriptOptions
    attr_accessor :user_token, :component_name, :component_type, :branch, :flavour, :brand_id, :environment, :version, :dynamic_insertion_params, :recipe, :config, :author, :baseconfig_id, :changes_infra, :url, :entry_point
    # REQUIRED = [:url, :entry_point]

    def required
      [:url, :entry_point]
    end

    def define_options(parser)
      parser.banner = "Usage: cli.rb [options]"
      parser.separator ""
      parser.separator "Specific options:"

      # add additional options
      url(parser)
      entry_point(parser)
      verbose(parser)
      user_token(parser)
      component_name(parser)
      component_type(parser)
      branch(parser)
      flavour(parser)
      brand_id(parser)
      environment(parser)
      version(parser)
      dynamic_insertion_params(parser)
      recipe(parser)
      config(parser)
      author(parser)
      baseconfig_id(parser)
      changes_infra(parser)

      parser.separator ""
      parser.separator "Common options:"

      parser.on_tail("-h", "--help", "Show this message") do
        puts parser
        exit
      end
    end

    def entry_point(parser)
      parser.on("-e", "--entry_point [EP]",
                "Entry point of the API to be called") do |ep|
        self.entry_point = ep
      end
    end

    def url(parser)
      parser.on("--url [url]",
                "Url where to find the API") do |url|
        self.url = url
      end
      if !parser.instance_variable_get(:@default_argv).include?("--url") and !ENV['api_url'].nil?
        parser.instance_variable_get(:@default_argv).append("--url")
        parser.instance_variable_get(:@default_argv).append(ENV['api_url'])
      end
    end

    def verbose(parser)
      parser.on("-v", "--verbose", "Run verbosely") do |v|
        self.verbose = v
      end
    end

    def user_token(parser)
      parser.on("--user_token [user_token]",
                "user_token argument") do |user_token|
        self.user_token = user_token
      end
    end

    def component_name(parser)
      parser.on("--component_name [component_name]",
                "component_name argument") do |component_name|
        self.component_name = component_name
      end
    end

    def component_type(parser)
      parser.on("--component_type [component_type]",
                "component_type argument") do |component_type|
        self.component_type = component_type
      end
    end

    def branch(parser)
      parser.on("--branch [branch]",
                "branch argument") do |branch|
        self.branch = branch
      end
    end

    def flavour(parser)
      parser.on("--flavour [flavour]",
                "flavour argument") do |flavour|
        self.flavour = flavour
      end
    end

    def brand_id(parser)
      parser.on("--brand_id [brand_id]",
                "brand_id argument") do |brand_id|
        self.brand_id = brand_id
      end
    end

    def environment(parser)
      parser.on("--environment [environment]",
                "environment argument") do |environment|
        self.environment = environment
      end
    end

    def version(parser)
      parser.on("--version [version]",
                "version argument") do |version|
        self.version = version
      end
    end

    def dynamic_insertion_params(parser)
      parser.on("--dynamic_insertion_params [dynamic_insertion_params]",
                "dynamic_insertion_params argument") do |dynamic_insertion_params|
        self.dynamic_insertion_params = dynamic_insertion_params
      end
    end

    def recipe(parser)
      parser.on("--recipe [recipe]",
                "recipe argument") do |recipe|
        self.recipe = recipe
      end
    end

    def config(parser)
      parser.on("--config [config]",
                "config argument") do |config|
        self.config = config
      end
    end

    def author(parser)
      parser.on("--author [author]",
                "author argument") do |author|
        self.author = author
      end
    end

    def baseconfig_id(parser)
      parser.on("--baseconfig_id [baseconfig_id]",
                "baseconfig_id argument") do |baseconfig_id|
        self.baseconfig_id = baseconfig_id
      end
    end

    def changes_infra(parser)
      parser.on("--changes_infra [changes_infra]",
                "changes_infra argument") do |changes_infra|
        self.changes_infra = changes_infra
      end
    end
  end


  #
  # Return a structure describing the options.
  #
  def parse(args)
    # The options specified on the command line will be collected in
    # *options*.

    @options = ScriptOptions.new
    params = {}
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(into:params)
    end

    @options.required.each do |opt|
      raise ArgumentError, "#{opt} argument is required" unless params.has_key?(opt)
    end

    params
  end

  attr_reader :parser, :options
end


class ArgParserExecutionControl
  class ScriptOptions
    attr_accessor :table_name, :execution_is_full, :layer_name, :brand_id, :read_since, :written_to, :url, :entry_point
    # REQUIRED = [:table_name, :execution_is_full, :layer_name, :brand_id]

    def required
      [:table_name, :execution_is_full, :layer_name, :brand_id]
    end

    def define_options(parser)
      parser.banner = "Usage: cli.rb [options]"
      parser.separator ""
      parser.separator "Specific options:"

      # add additional options
      url(parser)
      entry_point(parser)
      verbose(parser)
      table_name(parser)
      execution_is_full(parser)
      layer_name(parser)
      brand_id(parser)
      read_since(parser)
      written_to(parser)

      parser.separator ""
      parser.separator "Common options:"

      parser.on_tail("-h", "--help", "Show this message") do
        puts parser
        exit
      end
    end

    def entry_point(parser)
      parser.on("-e", "--entry_point [EP]",
                "Entry point of the API to be called") do |ep|
        self.entry_point = ep
      end
    end

    def url(parser)
      parser.on("--url [url]",
                "Url where to find the API") do |url|
        self.url = url
      end
      if !parser.instance_variable_get(:@default_argv).include?("--url") and !ENV['api_url'].nil?
        parser.instance_variable_get(:@default_argv).append("--url")
        parser.instance_variable_get(:@default_argv).append(ENV['api_url'])
      end
    end

    def verbose(parser)
      parser.on("-v", "--verbose", "Run verbosely") do |v|
        self.verbose = v
      end
    end

    def table_name(parser)
      parser.on("--table_name [table_name]",
                "table_name argument") do |table_name|
        self.table_name = table_name
      end
    end

    def execution_is_full(parser)
      parser.on("--execution_is_full [execution_is_full]",
                "execution_is_full argument") do |execution_is_full|
        self.execution_is_full = execution_is_full
      end
    end

    def layer_name(parser)
      parser.on("--layer_name [layer_name]",
                "layer_name argument") do |layer_name|
        self.layer_name = layer_name
      end
    end

    def brand_id(parser)
      parser.on("--brand_id [brand_id]",
                "brand_id argument") do |brand_id|
        self.brand_id = brand_id
      end
    end

    def read_since(parser)
      parser.on("--read_since [read_since]",
                "read_since argument") do |read_since|
        self.read_since = read_since
      end
    end

    def written_to(parser)
      parser.on("--written_to [written_to]",
                "written_to argument") do |written_to|
        self.written_to = written_to
      end
    end
  end


  #
  # Return a structure describing the options.
  #
  def parse(args)
    # The options specified on the command line will be collected in
    # *options*.

    @options = ScriptOptions.new
    params = {}
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(into:params)
    end

    @options.required.each do |opt|
      raise ArgumentError, "#{opt} argument is required" unless params.has_key?(opt)
    end

    params
  end

  attr_reader :parser, :options
end
