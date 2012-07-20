require "spec_helper"

describe Player do

  it "should hash password" do
    password = "abc"
    Player.hash_password(password).should_not eq(password)
  end

  it "should create a new player" do
    Player.delete_all
    Player.count.should == 0
    Player.register("user1", "password1")
    Player.count.should == 1
  end

end