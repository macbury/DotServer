class Message
  MESSAGE_DELIMETER_START               = '<~'
  MESSAGE_DELIMETER_END                 = '~>'
  MESSAGE_TIMEOUT                       = 20

  attr_accessor :content

  def initialize(content)
    self.content
  end
end