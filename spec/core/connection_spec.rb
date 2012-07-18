require "spec_helper"

describe Connection do 
  before do 
    Server.messages = []
    Socket.stub(:unpack_sockaddr_in).and_return("0.0.0.0",3000)
    Connection.any_instance.stub(:get_peername)
    Connection.any_instance.stub(:send_data)
    Server.stub(:connections).and_return([])
  end
  
  it "should handle incoming message in one packet" do
    send_message                    = Message.build("foo", "bar", a: "b")
    connection                      = Connection.new(0)
    connection.handle_message_build(send_message.to_s)
    
    Server.messages.should_not be_empty
    Server.messages.size.should == 1
  end

  it "should handle incoming message in parts" do
    Server.messages.should be_empty
    
    send_message                    = Message.build("foo", "bar", a: "b")
    connection                      = Connection.new(0)
    send_message.to_s.chars.to_a.each_slice(7).to_a.each do |part|
      connection.handle_message_build(part.join(""))
    end
    
    Server.messages.should_not be_empty
    Server.messages.size.should == 1
  end
end