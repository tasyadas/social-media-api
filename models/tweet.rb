require 'date'
require 'fileutils'
require 'securerandom'

require_relative '../db/mysql_connector'
require_relative './user'
require_relative './comment'

include FileUtils::Verbose

class Tweet

  attr_accessor :id, :tweet, :media, :user, :tags, :comments, :updated_at, :created_at

  def initialize(param)
    @id         = param.key?(:id) ? param[:id] : SecureRandom.uuid
    @tweet      = param[:tweet]
    @media      = param.key?(:media) ? param[:media] : nil
    @user       = param[:user]
    @tags       = param.key?(:tags) ? param[:tags] : []
    @comments   = param.key?(:comments) ? param[:comments] : []
    @created_at = param.key?(:created_at) ? param[:created_at] : nil
    @updated_at = param.key?(:updated_at) ? param[:updated_at] : nil
  end

  def save
    filename = media ? media[:tempfile].path.split('/').last : media
    cp(media[:tempfile].path, "public/uploads/#{filename}") unless filename.nil?

    create_db_client.query(
      'INSERT INTO tweets ' +
      '(id, tweet, media, user_id)' +
      'VALUES ( ' +
        "'#{id}', "+
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
            "'#{id}', " +
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

  def self.get_all_tweet
    db_raw = create_db_client.query(
      'SELECT tweets.* ' +
      'FROM tweets'
    )

    tweets = Array.new

    db_raw.each do |data|
      tweet = Tweet.new({
        :id         => data["id"],
        :tweet      => data["tweet"],
        :media      => data["media"],
        :user       => data['user_id'],
        :created_at => data["created_at"],
        :updated_at => data["updated_at"],
      })

      tweets << tweet
    end

    tweets
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
      tweet   = tweets.find{|h| h.id == data['id']}
      tag     = data['tag_id'] ? Tag.find_single_tag(data['tag_id']) : nil
      comment = data['comment_id'] ? Comment.find_single_comment(data['comment_id']) : nil

      if tweet.nil?
        tweet = Tweet.new({
          :id         => data["id"],
          :tweet      => data["tweet"],
          :media      => data["media"],
          :user       => User.find_single_user(data['user_id']),
          :created_at => data["created_at"],
          :updated_at => data["updated_at"],
        })
        tweet.tags.push(tag) unless tag.nil?
        tweet.comments.push(comment) unless comment.nil?
        tweets.push(tweet)
      else
        tweet.tags.push(tag) unless tag.nil?
        tweet.comments.push(comment) unless comment.nil?
      end
    end

    tweets
  end

  def self.find_single_tweet(id)
    tweet = self.get_all_tweet.find{|x| x.id == id}

    if tweet.nil?
      raise "Tweet with id #{id} not found"
    end

    tweet
  end

  def self.get_last_item
    tweet = self.get_all_tweet.max_by{|x| x.created_at}

    if tweet.nil?
      raise "There is no Tweet"
    end

    tweet
  end
end