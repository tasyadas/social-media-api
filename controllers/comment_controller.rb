require_relative '../models/comment'

class CommentController
  def self.index
    Comment.get_all_comment_with_relation
  end
end