require_relative '../db/mysql_connector'
require_relative './user'
require "date"
require 'fileutils'

include FileUtils::Verbose

class Tweet

  attr_accessor :id, :tweet, :media, :user, :tags, :comments, :updated_at, :created_at

  def initialize(param)
    @id         = param.key?(:id) ? param[:id] : nil
    @tweet      = param[:tweet]
    @media      = param.key?(:media) ? param[:media] : nil
    @user       = param[:user]
    @tags       = param.key?(:tags) ? param[:tags] : []
    @comments   = param.key?(:comments) ? param[:comments] : []
    @created_at = param.key?(:created_at) ? param[:created_at] : nil
    @updated_at = param.key?(:updated_at) ? param[:updated_at] : nil
  end

  def save
    filename = media.tempfile.path.split('/').last
    cp(media.tempfile.path, "public/uploads/#{filename}")

    create_db_client.query(
      'INSERT INTO tweets ' +
      '(id, tweet, media, user_id)' +
      'VALUES ( ' +
        'UUID(), ' +
        "'#{tweet}', " +
        "'#{filename}', " +
        "'#{user}'" +
      ')'
    )

    if tags.length > 0
      tags.each do |tag|
        create_db_client.query(
          'INSERT INTO tag_tweet ' +
          '(tweet_id, tag_id)' +
          'VALUES ( ' +
            "select id from tweets order by created_at desc limit 1, " +
            "'#{tag.id}'" +
          ')'
        )
      end
    end

    true
  end

  def validate
    return "tweet cannot be empty" if tweet.nil?
    return "user_id cannot be null" if user.nil?
    return "You reached the character limit" if tweet.length >= 1000
    true if User.find_single_user(user)
  end

  def self.get_all_tweet_with_relation
    db_raw = create_db_client.query(
      'SELECT tweets.*, ' +
      'tag_tweet.tag_id AS tag_id, ' +
      'comments.id AS comment_id ' +
      'FROM tweets ' +
      'LEFT JOIN tag_tweet ON tag_tweet.tweet_id = tweets.id ' +
      'LEFT JOIN comments ON comments.tweet_id = tweets.id'
    )

    tweets = Array.new

    db_raw.each do |data|
      tweet = Tweet.new({
          :id         => data["id"],
          :tweet      => data["tweet"],
          :user       => User.find_single_user(data['user_id']),
          :created_at => data["created_at"],
          :updated_at => data["updated_at"],
        })

      tweets.push(tweet)
    end

    tweets
  end

  def self.find_single_tweet(id)
    tweet = self.get_all_tweet_with_relation.find{|x| x.id == id}

    if tweet.nil?
      raise "Tweet with id #{id} not found"
    end

    tweet
  end

  def self.get_last_item
    tweet = self.get_all_tweet_with_relation.max_by{|x| x.created_at}

    if tweet.nil?
      raise "There is no Tweet"
    end

    tweet
  end
end