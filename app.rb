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

get '/stats' do
  erb :stats, :locals => {:stats => stats}
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

def stats
  {
    :top_level_stats => [[datastore.llen("tweets"), "tweets since the beginning of time"]],
    :links => all_tweets.inject(Hash.new(0)){|acc, t| acc[t["message"]]+=1;acc}.to_a.sort_by{|a|a[1]}
  }
end

def datastore
  @datastore ||= Redis.new
end
