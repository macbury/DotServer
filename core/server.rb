class Server
  
  def initialize(options)
    @options = options
    Log.server.info "Starting server"
    @debug_interface = DebugInterface.new(self)
    Signal.trap("INT")  { stop }
    Signal.trap("TERM") { stop }
    $stdout.sync = true
  end

  def start
    EventMachine::start_server @options[:listen], @options[:port], Connection
    Log.server.info "Listening on #{@options[:listen]}:#{@options[:port]}"
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

  def self.logger
    @@logger
  end

  def self.connections
    @@connections ||= []
  end
end

