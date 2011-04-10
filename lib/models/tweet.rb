require 'dm-core'
require 'dm-redis-adapter'

DataMapper.setup(:default, {:adapter  => "redis"})

class Tweet
  include DataMapper::Resource
  property :id,                Integer, :key => true
  property :message,           String
  property :profile_image_url, String
  property :time_posted,       DateTime
  property :username,          String
  property :follower_count,    Integer
  property :translated_text,   String
  property :translated_from,   String

  def has?(property)
    properties = self.class.properties.map(&:name)
    return false unless properties.include?(property)
    !!self.__send__(property)
  end

  def marked_up_message
    message
  end

  def url
    "http://twitter.com/#!/#{username}/status/#{id}"
  end
end
