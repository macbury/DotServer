class AuthorizedController < Controller

  def initialize(session)
    super(session)
    throw "only authorized in players can execute this" if session.player.nil?
  end
end