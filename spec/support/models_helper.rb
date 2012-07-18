module FakeModels

  def stub_connection
    Socket.stub(:unpack_sockaddr_in).and_return(3000, "0.0.0.0")
    Connection.any_instance.stub(:get_peername)
    Connection.any_instance.stub(:send_data)
    EM.stub(:add_timer).and_return(nil)
    Server.stub(:connections).and_return([])

    Connection.new(Time.now.to_i)
  end

end