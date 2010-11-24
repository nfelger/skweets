require 'rubygems'
require 'json'
require 'sinatra'
require 'redis'
require 'action_view'
require 'active_support'

helpers { include ActionView::Helpers::DateHelper }

get '/' do
  erb :tweets, :locals => {:tweets => tweets}
end

get '/all' do
  erb :tweets, :locals => {:tweets => all_tweets}
end

def tweets
  last_seen_id = request.cookies["last_seen_tweet_id"].to_i

  tweets = datastore.lrange("tweets", 0, -1).
    map(&JSON.method(:parse)).
    select{|tweet| tweet["id"] > last_seen_id}

  response.set_cookie("last_seen_tweet_id", :value => tweets.map{|t| t["id"]}.max, :expires => 10.years.from_now) unless tweets.empty?
  tweets
end

def all_tweets
  datastore.lrange("tweets", 0, -1).map(&JSON.method(:parse))
end

def datastore
  @datastore ||= Redis.new
end
