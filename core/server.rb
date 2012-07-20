class Server
  
  attr_accessor :debug_interface

  def initialize(options)
    $server       = self
    @@connections = []
    @options      = options
    @@port        = @options[:port] 
    @@listen      = @options[:listen]
    @@env         = @options[:env]
    Log.server.info "Starting server #{Server.env}"

    self.debug_interface = DebugInterface.new(self)
    Signal.trap("INT")  { stop }
    Signal.trap("TERM") { stop }

    load_configuration
    init_database
    load_game
  end

  def load_configuration
    config_path = File.expand_path(@options[:config], Server.root)
    Log.server.info "Loading configuration files from #{config_path}"
    DConfig.load(File.join(config_path, "database.json"))
  end

  def init_database
    Log.server.info "Configuring connection to MongoDB"
    Mongoid.configure do |config|
      Mongoid.logger                        = Log.server
      Moped.logger                          = Log.server
      config.allow_dynamic_fields           = false
      config.identity_map_enabled           = false
      config.include_root_in_json           = true
      config.include_type_for_serialization = true
      config.preload_models                 = false
      config.protect_sensitive_fields       = true
      config.raise_not_found_error          = false
      config.skip_version_check             = false
      config.scope_overwrite_exception      = true
      config.use_activesupport_time_zone    = false
      config.use_utc                        = true
      
      config.sessions                       = { default: DConfig.database }
    end
  end
  
  def reload!
    Log.server.info "Reloading server data"
    load_game
  end

  def load_game
    Log.server.info "Loading game scripts..."
    Dir[File.join(Server.root, 'game/*.rb')].each do |file_path|
      Log.server.info "Loading #{file_path}"
      load(file_path)
    end
  end

  def start
    EventMachine::start_server Server.listen, Server.port, Connection
    Log.server.info "Listening on #{Server.listen}:#{Server.port}"
    if @options[:ui]
      self.debug_interface.start
    end
  end

  def stop
    Log.server.info "Stopping server now..."
    self.debug_interface.stop if @debug_interface
    EventMachine.stop
  end

  def self.env
    @@env
  end

  def self.env=(new_env)
    @@env = new_env
  end

  def self.port
    @@port
  end

  def self.listen
    @@listen
  end

  def self.connections
    @@connections
  end

  def self.connections
    @@connections ||= []
  end

  def self.root
    @@root_path
  end

  def self.root=(new_root_path)
    @@root_path = new_root_path
  end

  def self.context
    $server
  end

  def switch_to_console!
    Log.server.info "Switching to console"
    require "pry"
    Server.context.debug_interface.stop
    binding.pry
    Server.context.debug_interface.start
    Log.server.info "Switching back to debug interface"
  end
end

