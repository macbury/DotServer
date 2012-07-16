class EchoServer < EM::Connection
   def post_init
     puts "-- someone connected to the echo server!"
     @sid = RandChannel.subscribe { |m| send_data "#{m.inspect}\n" }
   end

   def receive_data(data)
     send_data ">>>you sent: #{data}"
     close_connection if data =~ /quit/i
   end

   def unbind
     puts "-- someone disconnected from the echo server!"
     RandChannel.unsubscribe @sid
  end
end
class Server
  def initialize
    @debug_interface = DebugInterface.new(self)
    Signal.trap("INT")  { stop }
    Signal.trap("TERM") { stop }
  end

  def start
    EventMachine::start_server "0.0.0.0", 15001, EchoServer
    tests
  end

  def enterDebugMode
    @debug_interface.start
  end

  def stop
    @debug_interface.stop if @debug_interface
    EventMachine.stop
  end
end

