require_relative '../models/tag'
require 'date'

class TagController

  def self.filter_by_hashtag(tag)
    tags = Tag.get_all_tag_with_relation.select{|x| (x.name).downcase == tag.downcase}
    return 'Hashtag not found' if tags.length == 0
    tags
  end

  def self.get_five_trending
    tags = Tag.get_all_tag_with_relation.select { |tag| DateTime.parse(tag.created_at.to_s) >= (DateTime.now - (24/24.0))}
    return 'There is no trending hashtag found' if tags.length == 0
    tags.sort_by! {|tag| -(tag.tweets.length + tag.comments.length)}.take(5)
  end
end