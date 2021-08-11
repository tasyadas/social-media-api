require_relative '../models/tweet'

class TweetController
  def self.index
    Tweet.get_all_tweet_with_relation
  end
end