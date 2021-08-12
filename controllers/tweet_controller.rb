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
      params[:tags].each do |data|
        tag = Tag.get_all_tag.find{|x| x.name == data}

        if tag.nil?
          tag = Tag.new({
            :name => data
          })
          tag.save
        end

        tweet.tags << Tag.get_last_item
      end
    end

    tweet.save
  end

  def self.filter_by_hashtag(tag)
    tags = Tag.get_all_tag_with_relation.select{|x| x.name.downcase == tag.downcase}
    return 'Hashtag not found' if tags.length == 0
    tags
  end
end