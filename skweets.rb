require 'rubygems'
require 'twitter'
require 'htmlentities'
require 'json'
require 'restclient'

def colors
  {
    :reset => "\033[m",
    :red   => "\033[1;31m",
    :green => "\033[32m",
    :blue  => "\033[36m"
  }
end

def paint(color, string)
  "#{colors[color]}#{string}#{colors[:reset]}"
end


boring_patterns = [
  /^I(’m going| might go) to/,
  /^I was there:.*http:\/\/l.songkick.com/,
  /^Check out this (upcoming|past).*http:\/\/l.songkick.com/
]
html_decoder = HTMLEntities.new
latest_id_filename = File.join(File.dirname(__FILE__), 'latest_id')
latest = (File.exists?(latest_id_filename) && IO.read(latest_id_filename).strip.to_i) || nil

while true
  entries = Twitter::Search.new('songkick').since_id(latest)
  entries.to_a.reverse.each do |entry|
    latest = entry.id
    File.open(latest_id_filename, 'w') { |f| f.puts(latest) }    

    next if boring_patterns.any? { |pattern| entry.text =~ pattern }  

    time_posted = Time.parse(entry.created_at).strftime("%a, %d-%b-%Y %T")
    
    text = html_decoder.decode(entry.text)
    translator_response = JSON.parse(RestClient.get('http://ajax.googleapis.com/ajax/services/language/translate', :params => { :v=>'1.0', :q => text, :langpair => '|en' } ))["responseData"]
    translated_text = html_decoder.decode(translator_response["translatedText"]) if translator_response
    language = translator_response["detectedSourceLanguage"] if translator_response
    
    text.gsub!(/@[^\s]+/, paint(:green, '\0'))
    text.gsub!(/https?:\/\/[^\s]+/, paint(:green, '\0'))
    
    puts paint(:red, '@' + entry.from_user) + "\t(#{time_posted})\t#{text}"
    puts "\t\t\t (Translated from #{language}:\t" + paint(:blue, translated_text) + ")" if translator_response and language != 'en'
  end
  sleep 300
end