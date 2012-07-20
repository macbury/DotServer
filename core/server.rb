class Server
  
  def initialize(options)
    @@connections = []
    @options      = options
    @@port        = @options[:port] 
    @@listen      = @options[:listen]
    @@env         = @options[:env]
    Log.server.info "Starting server #{Server.env}"

    @debug_interface = DebugInterface.new(self)
    Signal.trap("INT")  { stop }
    Signal.trap("TERM") { stop }
  end

  def load_configuration
    config_path = File.expand_path(@options[:config], Server.root)
    Log.server.info "Loading configuration files from #{config_path}"
    DConfig.load(File.join(config_path, "database.json"))
    puts DConfig.database.inspect
  end

  def init_database
    Log.server.info "Configuring connection to MongoDB"
    Mongoid.configure do |config|
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
      
      Log.server.info "Creating connection to mongodb"
      connection                = EM::Mongo::Connection.new
      Log.server.info "Selecting DB #{db_name}"
      config.databaseconnection = connection.db(db_name)
    end
  end
  
  def start
    load_configuration
    #init_database
    EventMachine::start_server Server.listen, Server.port, Connection
    Log.server.info "Listening on #{Server.listen}:#{Server.port}"
    if @options[:ui]
      @debug_interface.start
    end
  end

  def stop
    Log.server.info "Stopping server now..."
    @debug_interface.stop if @debug_interface
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
end

