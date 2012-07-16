class Connection < EM::Connection
  def post_init
    Server.logger.info "New connection"
  end

  def receive_data(data)
    send_data ">>>you sent: #{data}"
    close_connection if data =~ /quit/i
  end

  def unbind
    Server.logger.info "Connection closed"
  end
end