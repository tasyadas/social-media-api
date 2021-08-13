require 'securerandom'

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
    end

    context 'when given invalid parameter' do
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
        id = SecureRandom.uuid

        user = User.new({
          :id       => id,
          :username => 'tasyaaa',
          :email    => 'tasya@mail.com'
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with(
          'INSERT INTO users (id, username, email, bio)' +
          'VALUES (' +
          "'#{id}', " +
          "'#{user.username}'," +
          "'#{user.email}'," +
          "'#{user.bio}')"
        )

        expect(user.save).to eq(true)
      end
    end
  end

  describe '#delete' do
    context 'when given valid parameter' do
      it 'should delete one user from db' do
        user = User.get_last_item

        expect(user.delete).to eq(true)
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

  describe '#find_single_user' do
    context "when id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { User.find_single_user(id) }.to raise_error("User with id #{id} not found")
      end
    end

    context "when id exist" do
      it 'should return hash of User model' do
        id = User.get_last_item.id
        expect(User.find_single_user(id)).to be_a(User)
      end
    end
  end

  describe '#update' do
    context "when given valid parameters" do
      it 'should return true' do
        user = User.get_last_item

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with(
          'UPDATE users ' +
            'SET ' +
            "username = '#{user.username}'," +
            "email = '#{user.email}'," +
            "bio = '#{user.bio}'," +
            'updated_at = CURRENT_TIMESTAMP ' +
            "WHERE id = '#{user.id}'"
        )

        expect(user.update).to eq(true)
      end
    end
  end

  describe '#get_last_item' do
    context 'when table users is not empty' do
      it 'should return hash of User model' do
        expect(User.get_last_item).to be_a(User)
      end
    end

    context 'when table users is empty' do
      before(:each) do
        create_db_client(0).query("TRUNCATE TABLE users")
      end

      it 'should return hash of User model' do
        expect { User.get_last_item }.to raise_error("There is no User")
      end
    end
  end
end