require_relative '../db/mysql_connector'
require_relative './tag'
require_relative './tweet'

class Comment
  attr_accessor :id, :comment, :media, :user, :tweet, :tags, :created_at, :updated_at
  @@client = create_db_client

  def initialize(param)
    @id         = param.key?(:id) ? param[:id] : nil
    @comment    = param[:comment]
    @media      = param.key?(:media) ? param[:media] : nil
    @user       = param[:user]
    @tweet      = param[:tweet]
    @tags       = param.key?(:tags) ? param[:tags] : []
    @created_at = param.key?(:created_at) ? param[:created_at] : nil
    @updated_at = param.key?(:updated_at) ? param[:updated_at] : nil
  end

  def save
    filename = media.tempfile.path.split('/').last
    cp(media.tempfile.path, "public/uploads/#{filename}")

    @@client.query(
      'INSERT INTO comments ' +
      '(id, comment, media, user_id, tweet_id)' +
      'VALUES ( ' +
        'UUID(), ' +
        "'#{comment}', " +
        "'#{filename}', " +
        "'#{user}', " +
        "'#{tweet}'" +
      ')'
    )

    if tags.length > 0
      tags.each do |tag|
        @@client.query(
          'INSERT INTO tag_comment ' +
          '(comment_id, tag_id)' +
          'VALUES ( ' +
            "(select id AS comment_id from comments order by created_at desc limit 1), " +
            "'#{tag.id}'" +
          ')'
        )
      end
    end

    true
  end

  def validate
    return "comment cannot be empty" if comment.nil?
    return "user_id cannot be null" if user.nil?
    return "tweet_id cannot be null" if tweet.nil?
    return "You reached the character limit" if comment.length >= 1000
    true if User.find_single_user(user) and Tweet.find_single_tweet(tweet)
  end

  def self.get_all_comment
    db_raw = @@client.query(
      'SELECT comments.* ' +
      'FROM comments'
    )

    comments = Array.new

    db_raw.each do |data|

      comment = Comment.new({
        :id           => data["id"],
        :comment      => data["comment"],
        :user         => User.find_single_user(data['user_id']),
        :tweet        => Tweet.find_single_tweet(data['tweet_id']),
        :created_at   => data["created_at"],
        :updated_at   => data["updated_at"],
      })

      comments.push(comment)
    end

    comments
  end

  def self.get_all_comment_with_relation
    db_raw = @@client.query(
      'SELECT comments.*, ' +
      'tag_comment.tag_id AS tag_id ' +
      'FROM comments ' +
      'LEFT JOIN tag_comment ON tag_comment.comment_id = comments.id'
    )

    comments = Array.new

    db_raw.each do |data|
      tag     = data['tag_id'] ? Tag.find_single_tag(data['tag_id']) : nil
      comment = comments.find{|h| h.id == data['id']}

      if comment
        comment.tags.push(comment) unless tag.nil?
      else
        comment = Comment.new({
          :id           => data["id"],
          :comment      => data["comment"],
          :user         => User.find_single_user(data['user_id']),
          :tweet        => Tweet.find_single_tweet(data['tweet_id']),
          :created_at   => data["created_at"],
          :updated_at   => data["updated_at"],
        })

        comment.tags.push(tag) unless tag.nil?
        comments.push(comment)
      end
    end

    comments
  end

  def self.find_single_comment(id)
    comment = self.get_all_comment.find{|x| x.id == id}

    if comment.nil?
      raise "Comment with id #{id} not found"
    end

    comment
  end

  def self.get_last_item
    comment = self.get_all_comment.max_by{|x| x.created_at}

    if comment.nil?
      raise "There is no Comment"
    end

    comment
  end
end