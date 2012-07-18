require "spec_helper"

describe Connection do 
  before do 
    Server.messages = []
    Socket.stub(:unpack_sockaddr_in).and_return(3000, "0.0.0.0")
    Connection.any_instance.stub(:get_peername)
    Connection.any_instance.stub(:send_data)
    Server.stub(:connections).and_return([])
  end
  
  it "should handle incoming message in one packet" do
    send_message                    = Message.build("foo", "bar", "a" => "b")
    connection                      = Connection.new(0)
    connection.handle_message_build(send_message.to_s)
    
    Server.messages.should_not be_empty
    Server.messages.size.should == 1
    
    recived_message = Server.messages[0]
    recived_message.action_name.should     == send_message.action_name
    recived_message.controller_name.should == send_message.controller_name
    recived_message.params.should          == send_message.params
  end

  it "should handle incoming message in parts" do
    Server.messages.should be_empty
    
    send_message                    = Message.build("foo", "a" => "b")
    connection                      = Connection.new(0)
    send_message.to_s.chars.to_a.each do |letter|
      connection.handle_message_build(letter)
    end
    
    Server.messages.should_not be_empty
    Server.messages.size.should == 1
    
    recived_message = Server.messages[0]
    recived_message.action_name.should     == send_message.action_name
    recived_message.controller_name.should == send_message.controller_name
    recived_message.params.should          == send_message.params
  end
  
  it "should close connection after buffer limit is exceed" do
    Server.messages.should be_empty
    connection = Connection.new(0)
    connection.should_receive(:close_connection).at_least(1)
    
    (Connection::BufferLimit + 1).times do |index|
      connection.handle_message_build('a')
      Server.messages.should be_empty
    end
  end
end