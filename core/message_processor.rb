class MessageProcessor
  def initialize
    @tickloop = EM.tick_loop do
      Log.server.info Time.now.to_s
    end
  end
end