require_relative '../../controllers/comment_controller'
require_relative '../../controllers/tweet_controller'

describe CommentController do
  before(:all) do
    @client = create_db_client(0)
    user = User.new({
      :username => 'syaaa',
      :email    => 'tasya@mail.com',
      :bio      => 'Welcome to my life!'
    })

    user.save

    @tweet = {
      :tweet => 'coba input media #coba #aja #jalanin #aja #GenerasiGigih',
      :media => Rack::Test::UploadedFile.new('./erd.png', 'image/png'),
      :user  => User.get_last_item.id
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

  describe '#index' do
    context 'when there is several data from database' do
      it 'should return array of Tweet instance' do
        expect(TweetController.index).to include(Tweet)
      end
    end
  end
end