require_relative './user_spec'
require_relative './comment_spec'
require_relative './tag_spec'
require_relative '../../models/tweet'
require_relative '../../models/comment'
require_relative '../../models/tag'
require_relative '../../models/user'
require 'rack/test'

describe Tweet do
  before(:all) do
    @client = create_db_client(0)
    user = User.new({
      :username => 'syaaa',
      :email    => 'tasya@mail.com',
      :bio      => 'Welcome to my life!'
    })

    user.save
  end

  after(:all) do
    @client.query("TRUNCATE TABLE tag_tweet")
    @client.query("TRUNCATE TABLE tag_comment")
    @client.query("TRUNCATE TABLE tags")
    @client.query("TRUNCATE TABLE comments")
    @client.query("TRUNCATE TABLE tweets")
    @client.query("TRUNCATE TABLE users")
  end

  describe "#validate" do
    context 'when given invalid parameter' do
      it 'should return tweet cannot be empty' do
        tweet = Tweet.new({
          :user => User.get_last_item.id,
        })

        expect(tweet.validate).to eq("tweet cannot be empty")
      end

      it 'should return user_id cannot be null' do
        tweet = Tweet.new({
          :tweet => 'Hello World!',
        })

        expect(tweet.validate).to eq("user_id cannot be null")
      end

      it 'should return You reached the character limit' do
        tweet = Tweet.new({
          :tweet => 'ini tasya, tasya yang membuat tweet ini, tasya sedang mengetik, tasya melihat layar monitor, sekarang pukul 11.45, tasya sedang memikirkan bagaimana test case selanjutnya, apakah code akan tercover 100 persen? ' +
            'ini tasya, tasya yang membuat tweet ini, tasya sedang mengetik, tasya melihat layar monitor, sekarang pukul 11.45, tasya sedang memikirkan bagaimana test case selanjutnya, apakah code akan tercover 100 persen? ' +
            'ini tasya, tasya yang membuat tweet ini, tasya sedang mengetik, tasya melihat layar monitor, sekarang pukul 11.45, tasya sedang memikirkan bagaimana test case selanjutnya, apakah code akan tercover 100 persen? ' +
            'ini tasya, tasya yang membuat tweet ini, tasya sedang mengetik, tasya melihat layar monitor, sekarang pukul 11.45, tasya sedang memikirkan bagaimana test case selanjutnya, apakah code akan tercover 100 persen? ' +
            'ini tasya, tasya yang membuat tweet ini, tasya sedang mengetik, tasya melihat layar monitor, sekarang pukul 11.45, tasya sedang memikirkan bagaimana test case selanjutnya, apakah code akan tercover 100 persen? ',
          :user  => User.get_last_item.id
        })

        expect(tweet.validate).to eq("You reached the character limit")
      end

      it 'should raise an error' do
        tweet = Tweet.new({
           :tweet => 'Hello World!',
           :user  => '1'
         })

        expect { tweet.validate }.to raise_error("User with id #{tweet.user} not found")
      end
    end

    context 'when given valid parameter' do
      it 'should return true' do
        tweet = Tweet.new({
          :tweet => 'tasyaaa',
          :user  => User.get_last_item.id
        })

        expect(tweet.validate).to eq(true)
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

        tweet = Tweet.new({
          :tweet => 'coba input media',
          :user  => User.get_last_item.id
        })
        tweet.tags << tag

        expect(tweet.save).to eq(true)
      end
    end
  end

  describe "#get_all_tweet" do
    context 'when there is several data from database' do
      it 'should return array of Tweet instance' do
        expect(Tweet.get_all_tweet).to include(Tweet)
      end
    end

    context 'when there is no data in database' do
      it 'should return empty array' do
        @client.query("TRUNCATE TABLE tweets")

        expect(Tweet.get_all_tweet).to eq([])
      end
    end
  end

  describe "#get_all_tweet_with_relation" do
    before(:all) do
      tag = Tag.new({
        :name => 'GenerasiGigih',
      })
      tag.save
      tag = Tag.get_last_item

      tweet = Tweet.new({
        :tweet => 'coba input media',
        :user  => User.get_last_item.id
      })
      tweet.tags << tag
      tweet.save

      comment = Comment.new({
        :comment => 'coba input media',
        :user    => User.get_last_item.id,
        :tweet   => Tweet.get_last_item.id
      })
      comment.tags << tag
      comment.save

      @tweets   = Tweet.get_all_tweet_with_relation
    end

    context 'when there is several data from database' do
      it 'should call #find_single_user' do
        id = User.get_last_item.id
        expect(User.find_single_user(id)).to be_a(User)
      end

      it 'should return array of Tweet instance' do
        expect(@tweets).to include(Tweet)
      end

      it 'should call #get_all_comment' do
        expect(Comment.get_all_comment).to include(Comment)
      end

      it 'should return hash of Comment model' do
        tweet   = @tweets.find{|x| x.comments.length > 0}
        id      = tweet.comments[0].id

        expect(Comment.find_single_comment(id)).to be_a(Comment)
      end

      it 'should call #get_all_tag' do
        expect(Tag.get_all_tag).to include(Tag)
      end

      it 'should return hash of Tag model' do
        tweet   = @tweets.find{|x| x.tags.length > 0}
        id      = tweet.tags[0].id

        expect(Tag.find_single_tag(id)).to be_a(Tag)
      end
    end

    context "when user_id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { User.find_single_user(id) }.to raise_error("User with id #{id} not found")
      end
    end

    context "when comment_id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { Comment.find_single_comment(id) }.to raise_error("Comment with id #{id} not found")
      end
    end

    context "when tag_id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { Tag.find_single_tag(id) }.to raise_error("Tag with id #{id} not found")
      end
    end
  end

  describe "#find_single_tweet" do
    context "when id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { Tweet.find_single_tweet(id) }.to raise_error("Tweet with id #{id} not found")
      end
    end

    context "when id exist" do
      it 'should return hash of Tweet model' do
        tweet = Tweet.new({
          :tweet => 'coba input media',
          :user => User.get_last_item.id
        })

        tweet.save

        id = Tweet.get_last_item.id
        expect(Tweet.find_single_tweet(id)).to be_a(Tweet)
      end
    end
  end

  describe '#get_last_item' do
    context 'when table tweets is not empty' do
      it 'should return hash of Tweet model' do
        expect(Tweet.get_last_item).to be_a(Tweet)
      end
    end

    context 'when table tweets is empty' do
      it 'should return There is no Tweet' do
        @client.query("TRUNCATE TABLE tweets")

        expect { Tweet.get_last_item }.to raise_error("There is no Tweet")
      end
    end
  end
end
