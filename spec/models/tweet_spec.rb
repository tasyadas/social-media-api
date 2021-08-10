require_relative '../../models/tweet'
require_relative '../../models/user'
require 'rack/test'

describe Tweet do
  before(:all) do
    user = User.new({
      :username => 'syaaa',
      :email    => 'tasya@mail.com',
      :bio      => 'Welcome to my life!'
    })

    user.save
  end

  describe "#valid?" do
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
        tweet = Tweet.new({
          :tweet => 'coba input media',
          :media => Rack::Test::UploadedFile.new('./erd.png', 'image/png'),
          :user => User.get_last_item.id
        })

        expect(tweet.save).to eq(true)
      end
    end
  end

  describe "#get_all_tweet_with_relation" do
    context 'when there is several data from database' do
      it 'should return array of Tweet instance' do
        expect(Tweet.get_all_tweet_with_relation).to include(Tweet)
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
  end

  describe '#get_last_item' do
    context 'when table tweets is not empty' do
      it 'should return hash of Tweet model' do
        expect(Tweet.get_last_item).to be_a(Tweet)
      end
    end

    context 'when table tweets is empty' do
      it 'should return There is no Tweet' do
        create_db_client(0).query("TRUNCATE TABLE tweets")

        expect { Tweet.get_last_item }.to raise_error("There is no Tweet")
      end
    end
  end
end
