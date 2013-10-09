class User < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :twitter_user_id, uniqueness: true

  def self.fetch_by_screen_name
    user_url = Addressable::URI.new(
      :scheme => 'https',
      :host => 'api.twitter.com',
      :path => '1.1/users/show.json',
      :query_values => { :screen_name => self.screen_name }
    ).to_s

    returned = TwitterSession.get(user_url).body
    User.parse_twitter_params(returned)
  end

  def self.parse_twitter_params(params)
    User.new(JSON.parse(params))
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
