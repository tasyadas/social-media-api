require_relative '../db/mysql_connector'
require_relative './user'

class Tweet

  attr_accessor :id, :tweet, :media, :user, :tags

  def initialize(param)
    @id    = param.key?(:id) ? param[:id] : nil
    @tweet = param[:tweet]
    @media = param.key?(:media) ? param[:media] : nil
    @user  = param[:user]
    @tags  = param.key?(:tags) ? param[:tags] : []
  end

  def validate
    return "tweet cannot be empty" if tweet.nil?
    return "user_id cannot be null" if user.nil?
    return "You reached the character limit" if tweet.length >= 1000
    true if User.find_single_user(user)
  end
end