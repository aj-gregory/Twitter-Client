class Status < ActiveRecord::Base
  attr_accessible :twitter_status_id, :body, :twitter_user_id, :user_id
  validates :twitter_status_id, :uniqueness => true

  def self.parse_twitter_status(params)
    Status.create!(params)
  end

  def self.fetch_statuses_for_user(user)
    status_url = Addressable::URI.new(
      :scheme => 'https',
      :host => 'api.twitter.com',
      :path => '1.1/statuses/user_timeline.json',
      :query_values => { :screen_name => user.screen_name }
    ).to_s

    returned = JSON.parse(TwitterSession.get(status_url).body)

    params = []
    returned.each do |hash|
      selected = hash.select {|k,v| k == 'id' || k == 'text'}
      params << {:twitter_status_id => selected['id'],
                 :twitter_user_id => user.twitter_user_id, 
                 :user_id => user.id, :body => selected['text']}
    end

    persisted_statuses = Status.all

    status_ids = []
    persisted_statuses.each do |status|
      status_ids << status.twitter_status_id
    end

    new_statuses = []
    params.each do |hash|
      unless status_ids.include?(hash[:twitter_status_id])
        new_statuses << Status.parse_twitter_status(hash)
      end
    end

    persisted_statuses + new_statuses
  end

  belongs_to( :author,
              :class_name => "User",
              :foreign_key => :twitter_user_id,
              :primary_key => :twitter_user_id
            )

end
