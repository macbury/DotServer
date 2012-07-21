require 'digest/sha1'

class Player
  include Mongoid::Document
  field :login, type: String
  field :password_hash, type: String

  def self.hash_password(password)
    Digest::SHA1.hexdigest(password)
  end

  def self.register(login, password)
    Player.create login: login, password_hash: Player.hash_password(password)
  end

  def self.auth(login, password)
    player = Player.find_by login: login, password_hash: password
  end

  def bootup_package
    { x: 0, y: 0, map: 'eee' }
  end
end