class CoreObject
  def initialize
    @@track_objects ||= []
    @@track_objects << self if Server.env != "production"
  end
  
  def self.reload!
  
  end
end