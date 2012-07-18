class Controller
  ServerPrefix = "server"
  attr_accessor :session

  def initialize(session)
    raise "Must be a session object but is #{session.class.inspect}" unless session.kind_of?(Session)
    self.session = session
  end
end