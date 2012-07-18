require "socket"

class Connection < EM::Connection
  attr_accessor :session
  BufferLimit           = 2048

  def post_init
    @buffer       = nil
    @port, @ip    = Socket.unpack_sockaddr_in(get_peername)
    self.session  = Session.new(self)
    Server.connections << self

    Log.server.info "New connection from IP: #{@ip} on port #{@port}"
    send_data 0x0
  end

  def receive_data(data)
    if data == 0x0
      send_data 0x0
    else
      handle_message_build(data)
    end
  end

  def handle_message_build(data)
    @buffer = "" if @buffer.nil?
    @buffer << data.strip
    if @buffer.match(/(#{Regexp.escape(Message::MESSAGE_DELIMETER_START)}.+#{Regexp.escape(Message::MESSAGE_DELIMETER_END)})/i)
      Server.messages << Message.parse($1)
      @buffer = nil
    elsif @buffer.size > Connection::BufferLimit
      Log.server.warn "IP: #{@ip} on port #{@port} exceed buffer limit!"
      close_connection
    end
  end

  def unbind
    Log.server.info "Connection closed for #{@ip}"
    Server.connections.delete(self)
  end

end