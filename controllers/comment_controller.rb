require 'securerandom'

require_relative '../models/comment'

class CommentController
  def self.index
    Comment.get_all_comment_with_relation
  end

  def self.create(params)
    comment = Comment.new(params)
    comment.validate

    params[:comment].scan(/(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/) do |m|
      tag = Tag.get_all_tag.find{|x| x.name == m[0]}

      if tag.nil?
        id = SecureRandom.uuid
        tag = Tag.new({
          :id   => id,
          :name => m[0]
        })
        tag.save
      end

      is_tag_exist = comment.tags.any? { |h| h.id == tag.id}

      comment.tags << Tag.find_single_tag(tag.id) unless is_tag_exist
    end

    comment.save
  end
end