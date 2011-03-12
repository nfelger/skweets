require 'rubygems'
require File.join(File.dirname(__FILE__), 'webapp.rb')

DataMapper.setup(:default, {:adapter  => "redis"})

run Skweets