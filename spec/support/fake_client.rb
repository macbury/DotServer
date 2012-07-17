class FakeClient < EventMachine::Connection
  attr_reader :packets

  def onopen(&blk);     @onopen = blk;    end
  def onclose(&blk);    @onclose = blk;   end
  def onerror(&blk);    @onerror = blk;   end
  def onmessage(&blk);  @onmessage = blk; end

  def initialize
    @state = :new
    @packets = []
  end

  def post_init
    send_data(0x0)
  end

  def receive_data(data)
    #puts "RECEIVE DATA #{data}"
    if @state == :new
      @onopen.call if @onopen
      @state = :open
    else
      @onmessage.call(data) if @onmessage
      @packets << data
    end
  end

  def send(data)
    send_data("\x00#{data}\xff")
  end

  def unbind
    @onclose.call if @onclose
  end
end