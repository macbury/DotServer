require "socket"

class Connection < EM::Connection
  attr_accessor :session
  BufferLimit           = 2048

  def post_init
    @buffer       = nil
    @port, @ip    = Socket.unpack_sockaddr_in(get_peername)
    Log.server.info "New connection from IP: #{@ip} on port #{@port}"
    self.session  = Session.new(self)
    Server.connections << self

    send_data 0x0
  end

  def receive_data(data)
    if data == 0x0
      send_data 0x0
    else
      handle_message_build(data)
    end
  end

  def deliver(message)
    send_data message.to_s
  end

  def deliver_error(error_text)
    deliver(Message.build_error(error_text))
  end

  def handle_message_build(data)
    @buffer = "" if @buffer.nil?
    @buffer << data.strip
    if @buffer.match(Message::Regexp)
      self.session.process($1)
      @buffer = nil
    elsif @buffer.size > Connection::BufferLimit
      Log.server.warn "IP: #{@ip} on port #{@port} exceed buffer limit!"
      deliver_error("Connection buffer exceed!")
      close_connection
    end
  end

  def unbind
    Log.server.info "Connection closed for #{@ip}"
    Server.connections.delete(self)
  end

end