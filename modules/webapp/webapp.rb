require 'rubygems'
require 'sinatra/base'
require 'action_view'
require File.expand_path(File.dirname(__FILE__) + '/../../lib/skweets.rb')

class Skweets < Sinatra::Base
  set :views, File.dirname(__FILE__) + '/views'
  helpers { include ActionView::Helpers::DateHelper }

  get '/' do
    erb :tweets, :locals => {:tweets => Tweet.all}
  end
end
