require 'rubygems'
require 'bundler'

Bundler.require

require File.expand_path('tf_runner', File.dirname(__FILE__))
run Sinatra::Application
