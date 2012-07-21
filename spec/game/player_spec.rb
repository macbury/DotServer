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

  it "should return nil for empty player" do
    Player.delete_all
    Player.auth("aaa","sss").should be_nil
  end

  it "should return nil for invalid password" do
    Player.delete_all
    Player.register("user1", "password1")
    Player.auth("user1","sss").should be_nil
  end

  it "should return a player for valid data" do
    Player.delete_all
    Player.register("user1", "password1")
    Player.auth("user1",Player.hash_password("password1")).should_not be_nil
  end

end