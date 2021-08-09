require_relative '../../models/tweet'
require_relative '../../models/user'

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
end
