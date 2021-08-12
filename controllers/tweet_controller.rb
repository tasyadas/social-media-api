require_relative '../models/tweet'
require_relative '../models/tag'

class TweetController
  def self.index
    Tweet.get_all_tweet_with_relation
  end

  def self.create(params)
    tweet = Tweet.new(params.except(:tags))
    tweet.validate

    if params.key?(:tags) and params[:tags].length > 0
      params[:tags].each do |tag|
        tag = Tag.get_all_tag.find{|x| x.name == tag}

        if tag.nil?
          tag = Tag.new({
            :name => tag
          })
          tag.save
        end

        tweet.tags << Tag.get_last_item
      end
    end

    tweet.save
  end
end