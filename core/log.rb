require 'logger'

module Log
  def self.create
    file             = File.open('./log/server.log', "w+")
    file.sync        = true
    @@server_logger  = Logger.new(file)
  end

  def self.server
    @@server_logger
  end

  def self.critical
    @@critical_logger  ||= Logger.new(File.open('./log/error.log', "w+"))
  end
end

Log.create