require 'logger'

module Log
  def self.server
    @@server_logger ||= AbstractLogger.new('./log/server.log')
  end

  def self.critical
    @@critical_logger  ||= AbstractLogger('./log/error.log', "w+")
  end
end
