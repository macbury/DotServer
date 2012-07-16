require 'rubygems'
require 'bundler/setup'

Bundler.require

$:.push File.expand_path('./', File.dirname(__FILE__))

require "core/server"
require "core/debug_interface"

at_exit do
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    puts "Finished..."
  else
    $server.stop
    File.open("error.log", 'w') do |f| 
      f.write($!.to_s)
      f.write($!.backtrace.join("\n"))
    end
  end
end

EventMachine::run { 
  $server = Server.new
  $server.enterDebugMode
  $server.start
}