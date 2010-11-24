require 'rubygems'
require 'redis'
require 'json'
require 'twitter'
require 'restclient'
require 'htmlentities'

@redis = Redis.new

def go!
  while true
    tweets.reverse.each do |tweet|
      @redis.lpush("tweets", tweet.to_json)
    end
    sleep 300
  end
end

def tweets
  boring_patterns = [
    /^I(’m going| might go) to/,
    /^I was there:.*http:\/\/l.songkick.com/,
    /^Check out this (upcoming|past).*http:\/\/l.songkick.com/
  ]
  html_decoder = HTMLEntities.new

  latest = @redis.get("last_seen_id").to_i

  search = Twitter::Search.new.q('songkick').per_page(100).since_id(latest)
  entries = search.fetch.entries
  log("#{entries.size} new tweets")
  the_tweets = entries.reverse.map do |entry|
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
      :followers_count => Twitter.user(entry.from_user).followers_count,
      :time_posted => time_posted,
      :tweet_url => "http://twitter.com/#!/#{entry.from_user}/status/#{entry.id}",
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

    tweet
  end.compact.reverse
  @redis.set("last_seen_id", latest)
  the_tweets
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
  # text.gsub!(/@[^\s]+/, paint(:green, '\0'))
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

go!
