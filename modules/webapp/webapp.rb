require 'rubygems'
require 'sinatra/base'

class Skweets < Sinatra::Base
  get '/' do
    erb :tweets, :locals => {:tweets => []}
  end
end
