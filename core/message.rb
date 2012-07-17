class Message
  attr_accessor :action_name, :controller_name, :params
  MESSAGE_DELIMETER_START               = '\u0000'
  MESSAGE_DELIMETER_END                 = '\xFF'
  MESSAGE_TIMEOUT                       = 20

  def self.build(controller, action, params={})
    message                 = Message.new
    message.action_name     = action
    message.controller_name = controller
    message.params          = params
    message
  end

  def self.parse(message_string)
    message_string.gsub!(MESSAGE_DELIMETER_START, '')
    message_string.gsub!(MESSAGE_DELIMETER_END, '')
    output = YAML.load(Ascii85.decode(message_string))
    message                  = Message.new
    message.action_name      = output[:action]
    message.controller_name  = output[:controller]
    message.params           = output[:params]
    message
  end

  def to_s
    out = {
      action:     self.action_name,
      controller: self.controller_name,
      params:     self.params
    }

    [Message::MESSAGE_DELIMETER_START, Ascii85.encode(out.to_yaml), Message::MESSAGE_DELIMETER_END].join("")
  end
end