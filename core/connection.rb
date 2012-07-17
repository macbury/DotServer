class Connection < EM::Connection
  def post_init
    Log.server.info "New connection"
  end

  def receive_data(data)
    send_data ">>>you sent: #{data}"
    close_connection if data =~ /quit/i
  end

  def unbind
    Log.server.info "Connection closed"
  end
end