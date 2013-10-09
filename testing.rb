require 'addressable/uri'
require_relative './lib/TwitterSession.rb'
require 'json'
#require_relative './app/models/user.rb'

status_url = Addressable::URI.new(
  :scheme => 'https',
  :host => 'api.twitter.com',
  :path => '1.1/statuses/user_timeline.json',
  :query_values => { :screen_name => 'kennyChand' }
).to_s

p returned = TwitterSession.get(status_url).body

#p User.parse_twitter_params(returned)
