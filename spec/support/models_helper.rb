module FakeModels

  def stub_connection_methods
    Socket.stub(:unpack_sockaddr_in).and_return(3000, "0.0.0.0")
    Connection.any_instance.stub(:get_peername)
    Connection.any_instance.stub(:send_data)
  end

  def stub_connection
    stub_connection_methods
    EM.stub(:add_timer).and_return(nil)
    Server.stub(:connections).and_return([])

    Connection.new(Time.now.to_i)
  end

  def build_controller(controller_class)
    controller_class.new(stub_connection)
  end

  def build_player
    Player.register("player_#{Time.now.to_i}", "password_#{Time.now.to_i}")
  end

end