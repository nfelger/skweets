require 'rubygems'
require 'json'
require 'redis'

datastore = Redis.new
tweets = datastore.lrange("tweets", 0, -1).map(&JSON.method(:parse))

require File.dirname(__FILE__) + '/../../lib/skweets'

tweets.each do |tweet|
  Tweet.create!(
    :id                => tweet["id"],
    :message           => tweet["message"],
    :profile_image_url => tweet["profile_image_url"],
    :follower_count    => tweet["followers_count"],
    :time_posted       => tweet["time_posted"],
    :username          => tweet["tweeter"],
    :translated_text   => tweet["translation"]["translated_text"],
    :translated_from   => tweet["translation"]["from_lang"]
  )
end