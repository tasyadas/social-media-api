require_relative '../../models/tweet'
require_relative '../../controllers/tweet_controller'

describe TweetController do
  describe '#index' do
    context 'when there is no data in database' do
      it 'should return empty array' do
        expect(TweetController.index).to eq([])
      end
    end

    context 'when there is several data from database' do
      it 'should return array of Tweet instance' do
        expect(TweetController.index).to include(Tweet)

        create_db_client(0).query("TRUNCATE TABLE tweets")
      end
    end
  end
end
