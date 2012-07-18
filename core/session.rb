class Session
  include AASM
  AuthorizationTimeout = 20
  attr_accessor :connection, :current_message

  aasm do
    state :idle, initial: true
    state :authorization, enter: :start_authorization_timeout, exit: :end_authorization_timeout
    state :ingame
    state :finish, enter: :disconnect

    event :start do
      transitions from: :idle, to: :authorization
    end

    event :logout do
      transitions from: [:authorization, :ingame], to: :finish
    end
  end


  def initialize(connection)
    self.connection = connection
    self.current_message = nil
    self.start!
  end

  def disconnect
    self.connection.close_connection
  end

  def process(message_content)
    begin
      self.current_message = Message.parse(message_content)
    rescue Exception => e
      self.connection.deliver_error(e.to_s)
      Log.server.error "While processing #{message_content}"
      Log.server.error e.to_s
      Log.server.debug e.backtrace.join("\n")
    end
  end

  def start_authorization_timeout
    Log.server.info "Authorization begin and will timeout in #{Session::AuthorizationTimeout}!"
    @authorization_timeout_timer = EventMachine::Timer.new( Session::AuthorizationTimeout ) do 
      Log.server.info "Authorization timout exceed!"
      self.connection.deliver_error("Authorization timeout")
      logout!
    end
  end

  def end_authorization_timeout
    @authorization_timeout_timer.cancel if @authorization_timeout_timer
  end
end