require_relative '../db/mysql_connector'
require_relative './tweet'

class Tag

  attr_accessor :id, :name, :tweets, :comments, :created_at, :updated_at

    def initialize(param)
      @id         = param.key?(:id) ? param[:id] : nil
      @name       = param[:name]
      @tweets     = param.key?(:tweets) ? param[:tweets] : []
      @comments   = param.key?(:comments) ? param[:comments] : []
      @created_at = param.key?(:created_at) ? param[:created_at] : nil
      @updated_at = param.key?(:updated_at) ? param[:updated_at] : nil
    end

  def save
    create_db_client.query(
      'INSERT INTO tags ' +
      '(id, name)' +
      'VALUES ( ' +
        'UUID(), ' +
        "'#{name}'" +
      ')'
    )

    true
  end

  def self.get_all_tag
    db_raw = create_db_client.query(
      'SELECT tags.*, ' +
        'tag_tweet.tweet_id AS tweet_id, ' +
        'tag_comment.comment_id AS comment_id ' +
        'FROM tags ' +
        'LEFT JOIN tag_tweet ON tag_tweet.tag_id = tags.id ' +
        'LEFT JOIN tag_comment ON tag_comment.tag_id = tags.id'
    )

    tags = Array.new

    db_raw.each do |data|

      tag = Tag.new({
        :id         => data["id"],
        :name       => data["name"],
        :created_at => data['created_at'],
        :updated_at => data['updated_at']
      })

      tags.push(tag)
    end

    tags
  end

  def self.get_all_tag_with_relation
    db_raw = create_db_client.query(
      'SELECT tags.*, ' +
      'tag_tweet.tweet_id AS tweet_id, ' +
      'tag_comment.comment_id AS comment_id ' +
      'FROM tags ' +
      'LEFT JOIN tag_tweet ON tag_tweet.tag_id = tags.id ' +
      'LEFT JOIN tag_comment ON tag_comment.tag_id = tags.id'
    )

    tags = Array.new

    db_raw.each do |data|

      tweet   = data['tweet_id'] ? Tweet.find_single_tweet(data['tweet_id']) : nil
      comment = data['comment_id'] ? Comment.find_single_comment(data['comment_id']) : nil
      tag     = tags.find{|h| h.id == data['id']}

      if tag
        tag.tweets.push(tweet) unless tweet.nil?
        tag.comments.push(comment) unless comment.nil?
      else
        tag = Tag.new({
          :id         => data["id"],
          :name       => data["name"],
          :created_at => data['created_at'],
          :updated_at => data['updated_at']
        })

        tag.tweets.push(tweet) unless tweet.nil?
        tag.comments.push(comment) unless comment.nil?

        tags.push(tag)
      end
    end

    tags
  end

  def self.find_single_tag(id)
    tag = self.get_all_tag_with_relation.find{|x| x.id == id}

    if tag.nil?
      raise "Tag with id #{id} not found"
    end

    tag
  end

  def self.get_last_item
    tag = self.get_all_tag_with_relation.max_by{|x| x.created_at}

    if tag.nil?
      raise "There is no Tag"
    end

    tag
  end
end