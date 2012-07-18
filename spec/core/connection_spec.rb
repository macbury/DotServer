require "spec_helper"

describe Connection do 
  before do 
    Socket.stub(:unpack_sockaddr_in).and_return(3000, "0.0.0.0")
    Connection.any_instance.stub(:get_peername)
    Connection.any_instance.stub(:send_data)
    EM.stub(:add_timer)
    Server.stub(:connections).and_return([])
  end

  it "should have a session object for each new connection" do
    connection                      = Connection.new(0)
    connection.session.should_not be_nil
  end

  it "should handle incoming message in one packet" do
    send_message                    = Message.build("foo", "bar", "a" => "b")
    connection                      = Connection.new(0)
    connection.session.current_message.should be_nil

    connection.handle_message_build(send_message.to_s)
    connection.session.current_message.should_not be_nil
    
    recived_message = connection.session.current_message
    recived_message.action_name.should     == send_message.action_name
    recived_message.controller_name.should == send_message.controller_name
    recived_message.params.should          == send_message.params
  end

  it "should handle incoming message in parts" do  
    send_message                    = Message.build("foo", "a" => "b")
    connection                      = Connection.new(0)
    connection.session.current_message.should be_nil

    send_message.to_s.chars.to_a.each do |letter|
      connection.handle_message_build(letter)
    end
    
    connection.session.current_message.should_not be_nil
    
    recived_message = connection.session.current_message
    recived_message.action_name.should     == send_message.action_name
    recived_message.controller_name.should == send_message.controller_name
    recived_message.params.should          == send_message.params
  end
  
  it "should close connection after buffer limit is exceed" do
    connection = Connection.new(0)
    connection.should_receive(:deliver_error).at_least(1)
    connection.should_receive(:close_connection).at_least(1)
    
    (Connection::BufferLimit + 1).times do |index|
      connection.handle_message_build('a')
      connection.session.current_message.should be_nil
    end
  end

  it "should throw exception on invalid data" do
    connection = Connection.new(0)
    connection.should_receive(:deliver_error).at_least(1)
    connection.handle_message_build(Message.wrap_in_delimeters("blablablabl"))
  end
end