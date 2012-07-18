class Message
  attr_accessor :action_name, :controller_name, :params
  MESSAGE_DELIMETER_START               = '\u0000'
  MESSAGE_DELIMETER_END                 = '\xFF'
  MESSAGE_TIMEOUT                       = 20
  Regexp                                = /(#{Regexp.escape(Message::MESSAGE_DELIMETER_START)}.+#{Regexp.escape(Message::MESSAGE_DELIMETER_END)})/i

  def self.build(controller, action, params={})
    message                 = Message.new
    message.action_name     = action
    message.controller_name = controller
    message.params          = params
    message
  end

  def self.build_error(error_text)
    Message.build("error", "error", "message" => error_text)
  end

  def self.parse(message_string)
    message_string.gsub!(MESSAGE_DELIMETER_START, '')
    message_string.gsub!(MESSAGE_DELIMETER_END, '')
    output                   = JSON.parse(Ascii85.decode(message_string))
    message                  = Message.new
    message.action_name      = output["action"]
    message.controller_name  = output["controller"].gsub(/[^a-zA-Z]/i,'')
    message.params           = output["params"]
    message
  end

  def to_s
    out = {
      action:     self.action_name,
      controller: self.controller_name,
      params:     self.params
    }

    Message.wrap_in_delimeters(Ascii85.encode(out.to_json, false))
  end

  def self.wrap_in_delimeters(content)
    [Message::MESSAGE_DELIMETER_START, content, Message::MESSAGE_DELIMETER_END].join("")
  end

  def execute!(connection)
    constant   = Object
    controller = constant.const_defined?(controller_name) ? constant.const_get(controller_name) : constant.const_missing(controller_name)
    controller = controller.new(connection)
    controller.send("#{Controller::ServerPrefix}_#{action_name}", params)
  end
end