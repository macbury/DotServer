require 'rubygems'
require 'logger'
require 'digest/sha1'
require 'bundler/setup'

Bundler.require :default, :test

require "mongo"

root_path = File.expand_path('./', File.dirname(__FILE__))
$:.push root_path

require "core/config"
require "core/server"

Server.root = root_path

require "core/abstract_logger"
require "core/log"
require "core/core_object"
require "core/at_exit"
require "core/debug_interface"
require "core/connection"
require "core/message"
require "core/session"
require "core/controller"
require "core/authorized_controller"
