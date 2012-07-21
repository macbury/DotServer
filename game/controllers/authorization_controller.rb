class AuthorizationController < Controller

  def server_login(options)
    player = Player.auth(options['login'], options['password'])

    if player
      Log.server.info "Player #{player.login} logged in succesful"
      self.session.player = player
      self.session.send_message("GameController", "setup", player.bootup_package)
    else
      Log.server.info "Player could not log in"
      self.session.deliver_error("Wrong login or password")
      self.session.logout!
    end
  end

end