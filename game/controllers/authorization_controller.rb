class AuthorizationController < Controller

  def server_login(options)
    player = Player.authorize(options['login'], options['password'])

    if player
      Log.server.info "Player #{player.login} logged in succesful"
      self.session.player = player
    else
      Log.server.info "Player #{player.login} could not log in"
      self.session.deliver_error("Wrong login or password")
      self.session.logout!
    end
  end

end