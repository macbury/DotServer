require "spec_helper"

describe Message do
  it "should serialize and deserialize message" do
    send_message    = Message.build("FooController", "bar", "a" => "b")
    recived_message = Message.parse(send_message.to_s)

    send_message.controller_name.should eq(recived_message.controller_name)
    send_message.action_name.should eq(recived_message.action_name)
    send_message.params.should eq(recived_message.params)
  end

  it "should execute proper controller and action for valid message" do
    send_message    = Message.build("FooController", "bar", "a" => "b")
    recived_message = Message.parse(send_message.to_s)
    FooController.any_instance.should_receive(:server_bar).with(recived_message.params).at_least(1)
    recived_message.execute!(stub_connection.session)
  end

  it "should raise NoMethodError for invalid message" do
    send_message    = Message.build("FooController", "not_existing_bar", "a" => "b")
    recived_message = Message.parse(send_message.to_s)
    lambda { recived_message.execute!(stub_connection.session) }.should raise_error(NoMethodError)
  end

  it "should raise NoMethodError for invalid params" do
    send_message    = Message.build("FooController", "attr_test")
    recived_message = Message.parse(send_message.to_s)
  end

  it "should raise NoMethodError for invalid params" do
    send_message    = Message.build("FooController", "attr_test", { "test" => "a" })
    recived_message = Message.parse(send_message.to_s)
  end
end