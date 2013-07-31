class EzConfig
  class NoConfigForEnv < StandardError; end

  PRODUCTION_REGEX  = /^production/

  class << self
    def configure(opt)
      @opt = opt
    end

    def instance
      @instance ||= new (@opt || {})
    end

    def [](k)
      instance[k]
    end

    def to_hash
      instance.to_hash
    end
  end

  def initialize(opt={})
    @env              = opt[:env].to_s || ENV['RACK_ENV'] || ENV['RAILS_ENV']
    @path             = opt[:path] || "#{Dir.pwd}/config/app_config"
    @production_regex = opt[:production_regex] || PRODUCTION_REGEX
  end

  def [](k)
    config(k)
  end

  def files
    Dir.glob File.join(@path, '*.yml')
  end

  def default_env
    @env =~ @production_regex ? 'production' : 'non_production'
  end

  # Let's build this only for the config requested. 
  # Eager loading the all the configs will barf when for instance you have a sidekiq.yml
  # that does not conform to conventions, but all the rest do.
  def config(key)
    @config ||= {}
    
    file = File.join(@path, "#{key}.yml")
    raise NoConfigForEnv, "File #{file} not found." unless File.exists?(file)
    
    return @config[key] unless @config[key].nil? ||   @config[key].empty?
    # @config[key] ||= {}
      
    yaml  = YAML.load_file file
    val   = yaml[@env] || yaml[default_env]

    raise NoConfigForEnv, "Environment #{@env} not found in #{file}" unless val

    @config[key] = val
    @config[key]
  end

  alias :to_hash :config
end
