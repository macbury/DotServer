require "socket"

class Connection < EM::Connection
  include AASM
  AUTHORIZATION_TIMEOUT = 40

  aasm column: :current_state do
    state :idle, initial: true
    state :authorization
    state :game
    state :finished

    event :start do
      transitions to: :authorization, from: :idle, enter: :start_authorization_timeout, exit: :end_authorization_timeout
    end

    event :authorize do
      transitions from: :authorization, to: :game
    end

    event :unauthorized do
      transitions from: :authorization, to: :finish, enter: :send_unauthorized_status 
    end

    event :finish do
      transitions from: [:authorization], to: :finished, enter: :close_connection
    end
  end

  def post_init
    @buffer    = nil
    @port, @ip = Socket.unpack_sockaddr_in(get_peername)
    Log.server.info "New connection from IP: #{@ip} on port #{@port}"
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

  def handle_message_build(data)
    if @buffer.nil? && data =~ /#{Regexp.escape(Message::MESSAGE_DELIMETER_START)}/i
      @buffer = ""
    end

    @buffer << data unless @buffer.nil?

    if !@buffer.nil? && data =~ /#{Regexp.escape(Message::MESSAGE_DELIMETER_END)}/i
      message = Message.parse(@buffer)
      Log.server.info message.inspect
    end
  end

  def unbind
    Log.server.info "Connection closed for #{@ip}"
    Server.connections.delete(self)
  end

  def send_unauthorized_status
    
  end
end