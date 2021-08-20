require 'securerandom'
require 'rack/test'

require_relative '../../controllers/comment_controller'
require_relative '../../controllers/tweet_controller'
require_relative '../../models/comment'
require_relative '../../models/user'
require_relative '../models/comment_spec'

describe CommentController do
  before(:all) do
    @client = create_db_client(0)
    @user_id = SecureRandom.uuid
    user = User.new({
      :id       => @user_id,
      :username => 'syaaa',
      :email    => 'tasya@mail.com',
      :bio      => 'Welcome to my life!'
    })
    user.save

    @tweet_id = SecureRandom.uuid
    TweetController.create({
      :id    => @tweet_id,
      :tweet => 'coba input media #coba #aja #jalanin #aja #GenerasiGigih',
      :user  => User.get_last_item.id
    })

    @comment = {
      :comment  => 'yeay akhirnya berhasil sampai disini #GenerasiGigih #generasi_gigih #semangat #hwaiting',
      :tweet    => @tweet_id,
      :user     => @user_id
    }
  end

  after(:all) do
    @client.query("TRUNCATE TABLE tag_tweet")
    @client.query("TRUNCATE TABLE tag_comment")
    @client.query("TRUNCATE TABLE tags")
    @client.query("TRUNCATE TABLE tweets")
    @client.query("TRUNCATE TABLE comments")
    @client.query("TRUNCATE TABLE users")
  end

  describe "#create" do
    context "when call create method" do
      it 'should validate the given params' do
        comment = Comment.new(@comment)

        expect(comment.validate).to eq(true)
      end

      it 'should return true' do
        expect(CommentController.create(@comment)).to eq(true)
      end
    end
  end

  describe '#index' do
    context 'when there is several data from database' do
      it 'should return array of Tweet instance' do
        expect(TweetController.index).to include(Tweet)
      end
    end
  end
end