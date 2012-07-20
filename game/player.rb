class Player
  include Mongoid::Document
  field :login, type: String
  field :password_hash, type: String
end