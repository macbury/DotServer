class Session
  attr_accessor :connection

  def initialize(connection)
    self.connection = connection
  end
end