class CoreObject
  def initialize
    @@track_objects ||= []
    @@track_objects << self if Server.env != "production"
  end
  
  def self.clean_tracked_objects!
    @@track_objects = []
  end

  def self.reload!
    old_tracked_objects = @@track_objects
    self.clean_tracked_objects!

    old_tracked_objects.each do |old_track_object|
      
    end
  end

  def self.tracked_objects
    @@track_objects
  end
end