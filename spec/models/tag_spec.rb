require_relative './comment_spec'
require_relative './tweet_spec'
require_relative '../../models/tag'
require_relative '../../models/tweet'
require_relative '../../models/comment'
require 'rack/test'

describe Tag do
  before(:all) do
    user = User.new({
      :username => 'syaaa',
      :email    => 'tasya@mail.com',
      :bio      => 'Welcome to my life!'
    })

    user.save
  end

  after(:all) do
    create_db_client(0).query("TRUNCATE TABLE tags")
    create_db_client(0).query("TRUNCATE TABLE comments")
    create_db_client(0).query("TRUNCATE TABLE tweets")
    create_db_client(0).query("TRUNCATE TABLE tag_tweet")
    create_db_client(0).query("TRUNCATE TABLE users")
  end

  describe "#save" do
    context "when given valid params" do
      it 'should return true' do
        tag = Tag.new({
          :name => 'GenerasiGigih',
        })

        expect(tag.save).to eq(true)
      end
    end
  end

  describe "#get_all_tag" do
    context 'when there is several data from database' do
      it 'should return array of Tag instance' do
        expect(Tag.get_all_tag_with_relation).to include(Tag)
      end
    end

    context 'when there is no data in database' do
      it 'should return empty array' do
        create_db_client(0).query("TRUNCATE TABLE tags")

        expect(Tag.get_all_tag_with_relation).to eq([])
      end
    end
  end

  describe "#get_all_tag_with_relation" do
    context 'when there is several data from database' do
      before(:all) do
        tag = Tag.new({
          :name => 'GenerasiGigih',
        })

        tag.save

        tweet = Tweet.new({
          :tweet => 'coba input media',
          :media => Rack::Test::UploadedFile.new('./erd.png', 'image/png'),
          :user  => User.get_last_item.id
        })

        tweet.tags << Tag.get_last_item

        tweet.save

        @tag = Tag.get_all_tag_with_relation
      end

      it 'should return array of Tag instance' do
        expect(@tag).to include(Tag)
      end

      it 'should call #get_all_tweet_with_relation' do
        expect(Tweet.get_all_tweet_with_relation).to include(Tweet)
      end

      it 'should return hash of Tweet model' do
        tag = @tag.find{|x| x.tweets.length > 0}
        id = tag.tweets[0].id

        expect(Tweet.find_single_tweet(id)).to be_a(Tweet)
      end
    end

    context "when tweet_id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { Tweet.find_single_tweet(id) }.to raise_error("Tweet with id #{id} not found")
      end
    end

    context "when comment_id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { Comment.find_single_comment(id) }.to raise_error("Comment with id #{id} not found")
      end
    end

    context 'when there is no data in database' do
      it 'should return empty array' do
        create_db_client(0).query("TRUNCATE TABLE tags")

        expect(Tag.get_all_tag_with_relation).to eq([])
      end
    end
  end

  describe "#find_single_tag" do
    context "when id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { Tag.find_single_tag(id) }.to raise_error("Tag with id #{id} not found")
      end
    end

    context "when id exist" do
      it 'should return hash of Tag model' do
        tag = Tag.new({
          :name => 'GenerasiGigih',
        })

        tag.save

        id = Tag.get_last_item.id
        expect(Tag.find_single_tag(id)).to be_a(Tag)
      end
    end
  end

  describe '#get_last_item' do
    context 'when table tags is not empty' do
      it 'should return hash of Tag model' do
        expect(Tag.get_last_item).to be_a(Tag)
      end
    end

    context 'when table tags is empty' do
      it 'should return There is no Tag' do
        create_db_client(0).query("TRUNCATE TABLE tags")

        expect { Tag.get_last_item }.to raise_error("There is no Tag")
      end
    end
  end
end
