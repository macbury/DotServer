require "spec_helper"

describe Server do
  default_timeout 1

  it "should remove and add connections from connection list" do
    as_server do |server|
      Server.connections.should be_empty
      socket = EM.connect(Server.listen, Server.port, FakeClient)
      socket.onopen do
        Server.connections.should_not be_empty
        socket.close_connection
      end
      socket.onclose { server.stop }
    end
    Server.connections.should be_empty
  end

end