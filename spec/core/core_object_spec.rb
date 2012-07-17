require "spec_helper"

describe CoreObject do

  before { CoreObject.clean_tracked_objects! }

  it "should track created object in test env and development env" do
    CoreObject.tracked_objects.should be_empty
    10.times { CoreObject.new }
    CoreObject.tracked_objects.should_not be_empty
    CoreObject.tracked_objects.size.should eq(10)
  end

  it "should clean trakced objects" do
    CoreObject.tracked_objects.should be_empty
    10.times { CoreObject.new }
    CoreObject.tracked_objects.should_not be_empty
    CoreObject.clean_tracked_objects!
    CoreObject.tracked_objects.should be_empty
  end

end