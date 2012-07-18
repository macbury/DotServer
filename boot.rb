require 'rubygems'
require 'logger'
require 'bundler/setup'

Bundler.require :default, :test

$:.push File.expand_path('./', File.dirname(__FILE__))

require "core/log"
require "core/core_object"
require "core/at_exit"
require "core/server"
require "core/debug_interface"
require "core/connection"
require "core/message"