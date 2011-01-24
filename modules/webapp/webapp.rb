require 'rubygems'
require 'sinatra/base'
require 'action_view'
require File.join(File.dirname(__FILE__), 'lib', 'models', 'tweet.rb')

class Skweets < Sinatra::Base
  helpers { include ActionView::Helpers::DateHelper }

  get '/' do
    erb :tweets, :locals => {:tweets => Tweet.all}
  end
end
