require "spec_helper"

describe Message do

  it "should serialize and deserialize message" do
    send_message    = Message.build("foo", "bar", a: "b")
    recived_message = Message.parse(send_message.to_s)

    send_message.controller_name.should eq(recived_message.controller_name)
    send_message.action_name.should eq(recived_message.action_name)
    send_message.params.should eq(recived_message.params)
  end

end