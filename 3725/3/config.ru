require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/base'
require 'active_record'

require 'sinatra/flash'

enable :sessions
require_relative './app/controllers/application_controller.rb'

Dir[File.join(File.dirname(__FILE__), './app/models', '*.rb')].each { |file| require file }

run ApplicationController
