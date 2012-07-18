require "spec_helper"

describe Session do

  it "should go to authorization state on start and add timeout wating" do
    EM.should_receive(:add_timer).at_least(1).and_return(1)
    session = Session.new(nil)
    session.authorization?.should be(true)
  end

  it "should disconnect on logout!" do
    EM.should_receive(:add_timer).at_least(1).and_return(1)
    EventMachine::Timer.any_instance.should_receive(:cancel).at_least(1)
    connection = stub_connection
    
    connection.should_receive(:close_connection).at_least(1)
    connection.session.authorization?.should be(true)
    connection.session.logout!

  end

end