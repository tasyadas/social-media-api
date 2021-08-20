require_relative '../../controllers/tag_controller'
require_relative '../../controllers/tweet_controller'
require_relative '../../models/user'
require_relative '../models/tag_spec'
require 'rack/test'

describe TagController do
  before(:all) do
    @client = create_db_client(0)
    user = User.new({
      :username => 'syaaa',
      :email    => 'tasya@mail.com',
      :bio      => 'Welcome to my life!'
    })

    user.save

    TweetController.create({
       :tweet => 'coba input media #coba #aja #jalanin #aja #GenerasiGigih',
       :user  => User.get_last_item.id
     })
  end

  after(:all) do
    @client.query("TRUNCATE TABLE tweets")
    @client.query("TRUNCATE TABLE comments")
    @client.query("TRUNCATE TABLE users")
  end

  describe "#filter_by_hashtag" do
    context "when there is the same tag in database" do
      it "should return tag with it's relation" do
        expect(TagController.filter_by_hashtag('GENERASIGIGIH')).to include(Tag)
      end
    end

    context "when there is no matching tag in database" do
      it "should return Hashtag not found" do
        expect(TagController.filter_by_hashtag('majuBersama')).to eq('Hashtag not found')
      end
    end
  end

  describe "#get_five_trending" do
    context "when there is trending hashtag found in the last 24 hours" do
      it 'should return array of Tag instance' do
        expect(TagController.get_five_trending).to include(Tag)
      end
    end

    context "when there is no trending hashtag found in the last 24 hours" do
      it "should return There is no trending hashtag found"  do
        @client.query("TRUNCATE TABLE tag_tweet")
        @client.query("TRUNCATE TABLE tag_comment")
        @client.query("TRUNCATE TABLE tags")

        expect(TagController.get_five_trending).to eq('There is no trending hashtag found')
      end
    end
  end
end