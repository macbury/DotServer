class Server
  @@logger = Logger.new(File.open('./log/server.log', File::WRONLY | File::APPEND))
  def initialize(options)
    @options = options
    Server.logger.info "Starting server"
    @debug_interface = DebugInterface.new(self)
    Signal.trap("INT")  { stop }
    Signal.trap("TERM") { stop }
    $stdout.sync = true
  end

  def start
    EventMachine::start_server @options[:listen], @options[:port], Connection
    Server.logger.info "Listening on #{@options[:listen]}:#{@options[:port]}"
  end

  def enterDebugMode
    Server.logger.info "Binding debug interface"
    @debug_interface.start
  end

  def stop
    Server.logger.info "Stopping server now..."
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

