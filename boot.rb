require 'rubygems'
require "logger"
require 'bundler/setup'
Bundler.require :default

$:.push File.expand_path('./', File.dirname(__FILE__))

require "core/server"
require "core/debug_interface"
require "core/connection"

at_exit do
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    Server.logger.info "Finished..."
  else
    Server.logger.error $!.to_s
    Server.logger.error $!.backtrace.join("\n")
    $server.stop
  end
end

EventMachine::run { 
  $server = Server.new
  $server.enterDebugMode
  $server.start
}