class Server
  
  def initialize(options)
    @@connections = []
    @@messages    = []
    @options      = options
    @@port        = @options[:port] 
    @@listen      = @options[:listen]
    @@env         = @options[:env]
    Log.server.info "Starting server #{Server.env}"

    @debug_interface = DebugInterface.new(self)
    Signal.trap("INT")  { stop }
    Signal.trap("TERM") { stop }
    $stdout.sync = true
  end

  def start
    EventMachine::start_server Server.listen, Server.port, Connection
    Log.server.info "Listening on #{Server.listen}:#{Server.port}"
  end

  def enterDebugMode
    Log.server.info "Binding debug interface"
    @debug_interface.start
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

  def self.messages
    @@messages ||= []
  end
  
  def self.messages=(new_messages)
    @@messages = new_messages
  end
end

