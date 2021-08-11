require_relative '../db/mysql_connector'
require_relative './tweet'

class Tag

  attr_accessor :id, :name, :tweets, :comments

  def initialize(param)
    @id        = param.key?(:id) ? param[:id] : nil
    @name      = param[:name]
    @tweets    = param.key?(:tweets) ? param[:tweets] : []
    @comments  = param.key?(:comments) ? param[:comments] : []
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

  def self.get_all_tag_with_relation
    db_raw = create_db_client.query(
      'SELECT tags.*, ' +
      'tag_tweet.tweet_id AS tweet_id, ' +
      'tag_comment.comment_id AS comment_id ' +
      'FROM tags ' +
      'LEFT JOIN tag_tweet ON tag_tweet.tag_id = tag.id ' +
      'LEFT JOIN tag_comment ON tag_comment.tag_id = tag.id'
    )

    tags = Array.new

    db_raw.each do |data|

      tweet   = data['tweet_id'] ? Tweet.find_single_tweet(data['tweet_id']) : null
      comment = data['comment_id'] ? Comment.find_single_comment(data['comment_id']) : null
      tag     = tags.find{|h| h.id == data['id']}

      if tag
        tag.tweets.push(tweet) if tweet
        tag.comments.push(comment) if comment
      else
        tag = Tag.new({
          :id     => data["id"],
          :name   => data["name"],
        })

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
end
