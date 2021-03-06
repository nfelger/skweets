require 'rubygems'
require 'redis'
require 'json'
require 'twitter'
require 'restclient'
require 'htmlentities'
require File.expand_path(File.dirname(__FILE__) + '/../../../lib/skweets.rb')

module Cistern
  class << self
    def blocked_users
      ['WhereToGoTonite']
    end
    
    def run!
      while true
        each_tweet do |tweet|
          tweet = Tweet.new(
            :id                => tweet[:id],
            :message           => tweet[:message],
            :profile_image_url => tweet[:profile_image_url],
            :follower_count    => tweet[:follower_count],
            :time_posted       => tweet[:time_posted],
            :username          => tweet[:tweeter]
          )
          
          next if blocked_users.include? tweet.username
          
          tweet.save!
        end
        sleep 300
      end
    end

    def each_tweet
      boring_patterns = [
        /^I(’m going| might go) to/,
        /^I was there:.*http:\/\/l.songkick.com/,
        /^Check out this (upcoming|past).*http:\/\/l.songkick.com/,
        /csrblast/i
      ]
      html_decoder = HTMLEntities.new

      latest = redis.get("last_seen_id").to_i

      search = Twitter::Search.new.q('songkick').per_page(100).since_id(latest)
      entries = search.fetch.entries
      log("#{entries.size} new tweets")
      entries.reverse.each do |entry|
        latest = entry.id if entry.id > latest.to_i

        if boring_patterns.any? { |pattern| entry.text =~ pattern }
          log("Skipping @#{entry.from_user}: \"#{entry.text}\"")
          next
        end

        time_posted = Time.parse(entry.created_at).strftime("%a, %d-%b-%Y %T")

        text = html_decoder.decode(entry.text)
        translator_response = JSON.parse(RestClient.get('http://ajax.googleapis.com/ajax/services/language/translate', :params => { :v=>'1.0', :q => text, :langpair => '|en' } ))["responseData"]
        translated_text = html_decoder.decode(translator_response["translatedText"]) if translator_response
        language = translator_response["detectedSourceLanguage"] if translator_response

        tweet = {
          :tweeter => entry.from_user,
          :follower_count => Twitter.user(entry.from_user).followers_count,
          :time_posted => time_posted,
          :message => spice_up(text),
          :profile_image_url => entry.profile_image_url,
          :id => entry.id
        }

        if translator_response and language != 'en'
          tweet[:translation] = {
            :from_lang => language,
            :translated_text => translated_text
          }
        end

        yield tweet
      end
      redis.set("last_seen_id", latest)

    rescue => e
      sleep 6000
      []
    end

    def redis
      @redis ||= Redis.new
    end

    def resolve_link(url)
      location = `curl -sIL '#{url}' | grep Location | tail -1`
      location = url.dup if location == ""
      location.sub!(/^\s*Location:\s*/, '')
      location.sub(/\/\s*$/, '')
    end

    def strip_crap(url)
      stripped = url.dup
      ["^https?://", "^www\\.", "[?&]utm_(content|source|campaign|medium)=[^&]*"].each do |pattern|
        stripped.gsub!(Regexp.new(pattern), '')
      end
      stripped
    end

    def spice_up(source_text)
      text = source_text.dup
      text.gsub!(/(https?:\/\/|www\.)[^\s]+/) do |url|
        resolved = resolve_link(url)
        stripped = strip_crap(resolved)
        "<a href='#{resolved}' target='_blank'>#{stripped}</a>"
      end
      text
    end

    def log(msg)
      STDOUT.puts msg
    end
  end
end
