require_relative '../../models/comment'
require_relative '../../models/tweet'
require_relative '../../models/user'
require_relative '../../models/tag'
require 'rack/test'

describe Comment do
  before(:all) do
    user = User.new({
      :username => 'syaaa',
      :email    => 'tasya@mail.com',
      :bio      => 'Welcome to my life!'
    })

    user.save

    @user   = User.get_last_item

    tweet = Tweet.new({
      :tweet => 'coba input media',
      :media => Rack::Test::UploadedFile.new('./erd.png', 'image/png'),
      :user  => @user.id
    })

    tweet.save

    @tweet  = Tweet.get_last_item
  end

  describe "#valid?" do
    context 'when given invalid parameter' do
      it 'should return comment cannot be empty' do
        comment = Comment.new({
          :user => @user.id,
        })

        expect(comment.validate).to eq("comment cannot be empty")
      end

      it 'should return user_id cannot be null' do
        comment = Comment.new({
          :comment => 'Hello World!',
        })

        expect(comment.validate).to eq("user_id cannot be null")
      end

      it 'should return tweet_id cannot be null' do
        comment = Comment.new({
          :comment => 'Hello World!',
          :user    => @user.id
        })

        expect(comment.validate).to eq("tweet_id cannot be null")
      end

      it 'should return You reached the character limit' do
        comment = Comment.new({
          :comment => 'ini tasya, tasya yang membuat comment ini, tasya sedang mengetik, tasya melihat layar monitor, sekarang pukul 11.45, tasya sedang memikirkan bagaimana test case selanjutnya, apakah code akan tercover 100 persen? ' +
            'ini tasya, tasya yang membuat comment ini, tasya sedang mengetik, tasya melihat layar monitor, sekarang pukul 11.45, tasya sedang memikirkan bagaimana test case selanjutnya, apakah code akan tercover 100 persen? ' +
            'ini tasya, tasya yang membuat comment ini, tasya sedang mengetik, tasya melihat layar monitor, sekarang pukul 11.45, tasya sedang memikirkan bagaimana test case selanjutnya, apakah code akan tercover 100 persen? ' +
            'ini tasya, tasya yang membuat comment ini, tasya sedang mengetik, tasya melihat layar monitor, sekarang pukul 11.45, tasya sedang memikirkan bagaimana test case selanjutnya, apakah code akan tercover 100 persen? ' +
            'ini tasya, tasya yang membuat comment ini, tasya sedang mengetik, tasya melihat layar monitor, sekarang pukul 11.45, tasya sedang memikirkan bagaimana test case selanjutnya, apakah code akan tercover 100 persen? ',
          :user  => @user.id,
          :tweet => @tweet.id
        })

        expect(comment.validate).to eq("You reached the character limit")
      end

      it 'should raise an error' do
        comment = Comment.new({
          :comment => 'Hello World!',
          :user    => '1',
          :tweet   => '2'
        })

        expect { comment.validate }.to raise_error("User with id #{comment.user} not found")
      end

      it 'should raise an error' do
        comment = Comment.new({
          :comment => 'Hello World!',
          :user    => @user.id,
          :tweet   => '2'
        })

        expect { comment.validate }.to raise_error("Tweet with id #{comment.tweet} not found")
      end
    end

    context 'when given valid parameter' do
      it 'should return true' do
        comment = Comment.new({
          :comment => 'tasyaaa',
          :user  => @user.id,
          :tweet => @tweet.id
        })

        expect(comment.validate).to eq(true)
      end
    end
  end

  describe "#save" do
    context "when given valid parameter" do
      it 'should return true' do
        tag = Tag.new({
          :name => 'GenerasiGigih',
        })
        tag.save
        tag = Tag.get_last_item

        comment = Comment.new({
          :comment => 'coba input media',
          :media   => Rack::Test::UploadedFile.new('./erd.png', 'image/png'),
          :user    => @user.id,
          :tweet   => @tweet.id
        })
        comment.tags << tag

        expect(comment.save).to eq(true)
      end
    end
  end

  describe "#get_all_comment_with_relation" do
    before(:all) do
      @comments = Comment.get_all_comment_with_relation
      @tags     = Tag.get_all_tag_with_relation
    end

    context 'when there is several data from database' do

      it 'should return array of Comment instance' do
        expect(@comments).to include(Comment)
      end

      it 'should call #get_all_tag_with_relation' do
        expect(@tags).to include(Tag)
      end

      it 'should return hash of Tag model' do
        comment = @comments.find{|x| x.tags.length > 0}
        id      = comment.tags[0].id

        expect(Tag.find_single_tag(id)).to be_a(Tag)
      end
    end

    context "when tag_id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { Tag.find_single_tag(id) }.to raise_error("Tag with id #{id} not found")
      end
    end
  end

  describe "#find_single_comment" do
    context "when id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { Comment.find_single_comment(id) }.to raise_error("Comment with id #{id} not found")
      end
    end

    context "when id exist" do
      it 'should return hash of Comment model' do
        id = Comment.get_last_item.id
        expect(Comment.find_single_comment(id)).to be_a(Comment)
      end
    end
  end

  describe '#get_last_item' do
    context 'when table comments is not empty' do
      it 'should return hash of Comment model' do
        expect(Comment.get_last_item).to be_a(Comment)
      end
    end

    context 'when table comments is empty' do
      it 'should return There is no Comment' do
        create_db_client(0).query("TRUNCATE TABLE comments")

        expect { Comment.get_last_item }.to raise_error("There is no Comment")
      end
    end
  end
end
