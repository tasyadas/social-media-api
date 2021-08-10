require_relative '../db/mysql_connector'

class Comment
  attr_accessor :id, :comment, :media, :user, :tweet, :tags, :created_at, :updated_at

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

    create_db_client.query(
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

    true
  end

  def validate
    return "comment cannot be empty" if comment.nil?
    return "user_id cannot be null" if user.nil?
    return "tweet_id cannot be null" if tweet.nil?
    return "You reached the character limit" if comment.length >= 1000
    true if User.find_single_user(user) and Tweet.find_single_tweet(tweet)
  end

  def self.get_all_comment_with_relation
    db_raw = create_db_client.query(
      'SELECT comments.*, ' +
      'tag_comment.tag_id AS tag_id ' +
      'FROM comments ' +
      'LEFT JOIN tag_comment ON tag_comment.comment_id = comments.id'
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

  def self.find_single_comment(id)
    comment = self.get_all_comment_with_relation.find{|x| x.id == id}

    if comment.nil?
      raise "Comment with id #{id} not found"
    end

    comment
  end

  def self.get_last_item
    comment = self.get_all_comment_with_relation.max_by{|x| x.created_at}

    if comment.nil?
      raise "There is no Comment"
    end

    comment
  end
end