require 'dm-core'
require 'dm-redis-adapter'

class Tweet
  include DataMapper::Resource
  property :id,                Integer, :key => true
  property :message,           String
  property :profile_image_url, String
  property :time_posted,       DateTime
  property :username,          String

  def has?(property)
    properties = self.class.properties.map(&:name)
    return false unless properties.include?(property)
    !!self.__send__(property)
  end

  def marked_up_message
    message
  end
end
