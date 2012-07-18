require "spec_helper"

describe Connection do 

  it "should handle incoming message in one packet" do
    Socket.stub(:unpack_sockaddr_in).and_return("0.0.0.0",3000)
    Connection.any_instance.stub(:get_peername)
    Connection.any_instance.stub(:send_data)
    Server.stub(:connections).and_return([])

    send_message                    = Message.build("foo", "bar", a: "b")
    connection                      = Connection.new(0)
    connection.handle_message_build(send_message.to_s)
    
    Server.messages.should_not be_empty
    Server.messages.size.should == 1
  end

end