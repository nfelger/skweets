require 'rubygems'
require 'sinatra/base'
require 'action_view'
require File.expand_path(File.dirname(__FILE__) + '/../../lib/skweets.rb')

class Skweets < Sinatra::Base
  set :app_file, __FILE__
  set :static,   true          # Serve static files from 'public/'

  helpers { include ActionView::Helpers::DateHelper }

  get '/' do
    erb :tweets, :locals => {
      :tweets =>       Tweet.all(:order => :time_posted.desc, :limit => 100),
      :last_seen_id => request.cookies["last_seen_tweet_id"].to_i
    }
  end
end
