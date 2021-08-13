require 'securerandom'

require_relative '../models/tweet'
require_relative '../models/tag'

class TweetController
  def self.index
    Tweet.get_all_tweet_with_relation
  end

  def self.create(params)
    tweet = Tweet.new(params)
    tweet.validate

    params[:tweet].scan(/(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/) do |m|
      tag = Tag.get_all_tag.find{|x| x.name == m[0]}

      if tag.nil?
        id = SecureRandom.uuid
        tag = Tag.new({
          :id   => id,
          :name => m[0]
        })
        tag.save
      end

      is_tag_exist = tweet.tags.any? { |h| h.id == tag.id}

      tweet.tags << Tag.find_single_tag(tag.id) unless is_tag_exist
    end

    tweet.save
  end
end