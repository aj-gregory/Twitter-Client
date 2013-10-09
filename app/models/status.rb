class Status < ActiveRecord::Base
  # attr_accessible :title, :body
  validates: :twitter_status_id, uniquness: true

  def self.parse_twitter_status(params)
    Status.new(JSON.parse(params))
  end

  def fetch_statuses_for_user(user)
    status_url = Addressable::URI.new(
      :scheme => 'https',
      :host => 'api.twitter.com',
      :path => '1.1/statuses/user_timeline.json',
      :query_values => { :screen_name => self.author.screen_name }
    ).to_s

    returned = TwitterSession.get(status_url).body

    persisted_statuses = author.statuses

    status_ids = []
    persisted_statuses.each do |status|
      status_ids << status.twitter_status_id
    end

    new_statuses = []
    returned.each do |hash|
      unless status_ids.include?(hash["id"])
        new_statuses << Status.parse_twitter_status(hash)
      end
    end

    persisted_statuses + new_statuses
  end

  belongs_to( :author,
              :class_name => "User",
              :foreign_key => :twitter_user_id
              :primary_key => :twitter_user_id
            )

end
