require "spec_helper"

describe AuthorizationController do

  it "should login user" do
    controller = build_controller(AuthorizationController)
    player = build_player
    controller.session.should_receive(:send_message).with("GameController", "setup", player.bootup_package).at_least(1).and_return(nil)
    controller.session.authorization?.should be(true) 
    controller.server_login( { 'login' => player.login, 'password' => player.password_hash } )
    controller.session.ingame?.should be(true)
    controller.session.player.should eq(player)

  end

end