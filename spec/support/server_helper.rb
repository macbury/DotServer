module ServerHelper
  include EM::SpecHelper

  def as_server(&block)
    em do
      @server = Server.new(port: 6000, listen: "127.0.0.1")
      @server.start
      yield @server
    end
  end
end