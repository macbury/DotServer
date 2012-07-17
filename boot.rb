require 'rubygems'
require 'bundler/setup'

Bundler.require :default

$:.push File.expand_path('./', File.dirname(__FILE__))

require "core/log"
require "core/at_exit"
require "core/server"
require "core/debug_interface"
require "core/connection"
