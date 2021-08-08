require_relative '../../models/user'

describe User do
  describe '#valid?' do
    context 'when given valid parameter' do
      it 'should return true' do
        user = User.new({
          :username => 'tasyaaa',
          :email    => 'tasya@mail.com'
        })

        expect(user.valid?).to eq(true)
      end

      it 'should return false' do
        user = User.new({
            :username => 'tasyaaa',
          })

        expect(user.valid?).to be_falsey
      end
    end
  end

  describe '#exist?' do
    before(:each) do
      create_db_client(0).query("TRUNCATE TABLE users")
    end

    context "when email or username doesn't exist yet" do
      it 'should return false' do
        user = User.new({
          :username => 'tasyaaa',
          :email    => 'tasya@mail.com'
        })

        expect(user.exist?).to be_falsey
      end
    end

    context "when email or username already exist" do
      it 'should return true' do
        user = User.new({
          :username => 'tasyaaa',
          :email    => 'tasya@mail.com'
        })

        user.save

        expect(user.exist?).to eq(true)
      end
    end
  end

  describe '#save' do
    context "when given valid parameter" do
      it 'should return true' do
        user = User.new({
          :username => 'tasyaaa',
          :email    => 'tasya@mail.com'
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with(
          'INSERT INTO users (id, username, email, bio)' +
          'VALUES (' +
          'UUID_TO_BIN(UUID()),' +
          "'#{user.username}'," +
          "'#{user.email}'," +
          "'#{user.bio}')"
        )

        expect(user.save).to eq(true)
      end
    end
  end

  describe '#get_all_user' do
    before(:each) do
      create_db_client(0).query("TRUNCATE TABLE users")
    end

    context 'when there is no data in database' do
      it 'should return empty array' do
        expect(User.get_all_user).to eq([])
      end
    end

    context 'when there is several data from database' do
      it 'should return array of User instance' do
        user = User.new({
          :username => 'tasyaaa',
          :email    => 'tasya@mail.com'
        })

        user.save

        expect(User.get_all_user).to include(User)
      end
    end
  end
end