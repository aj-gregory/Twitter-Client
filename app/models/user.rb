require 'TwitterSession.rb'

class User < ActiveRecord::Base
  attr_accessible :twitter_user_id, :screen_name 
  validates :twitter_user_id, uniqueness: true

  def self.fetch_by_screen_name(s_n)
    user_url = Addressable::URI.new(
      :scheme => 'https',
      :host => 'api.twitter.com',
      :path => '1.1/users/show.json',
      :query_values => { :screen_name => s_n }
    ).to_s

    returned = JSON.parse(TwitterSession.get(user_url).body)
    selected = returned.select {|k,v| k == 'id' || k == 'screen_name'}
    params = {:twitter_user_id => selected['id'], :screen_name => selected['screen_name']}
    User.parse_twitter_params(params)
  end

  def self.parse_twitter_params(params)
    p params
    User.new(params)
  end

  def sync_statuses
    statuses = Status.fetch_statuses_for_user(self)
    statuses.each do |status|
      status.save! unless status.persisted?
    end
  end

  has_many( :statuses,
            :class_name => "Status",
            :foreign_key => :twitter_user_id,
            :primary_key => :twitter_user_id,
          )
end
