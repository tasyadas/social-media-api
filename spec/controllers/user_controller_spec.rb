require_relative '../../controllers/user_controller'
require_relative '../../models/user'

describe UserController do
  describe '#create' do
    before(:each) do
      @params = {
        :username => 'tasyaaa',
        :email    => 'tasya@mail.com'
      }
    end

    context 'when given invalid parameter' do
      it 'should return string' do
        params = {:username => 'tasyaaa'}

        expect(UserController.create(params)).to eq('wrong parameter')
      end
    end

    context "when given valid parameter" do
      it 'should return true' do
        expect(UserController.create(@params)).to eq(true)
      end
    end

    context 'when given email or username that already exist' do
      it 'should return string' do
        expect(UserController.create(@params)).to eq('username or email already exist')
      end
    end
  end

  describe '#edit' do
    context 'when given invalid parameter' do
      it 'should return string' do
        params = {:username => 'tasyaaa'}

        expect(UserController.edit(params)).to eq('wrong parameter')
      end
    end

    context "when given valid parameter" do
      it 'should return true' do
        user = User.get_last_item
        param = {
          :id         => user.id,
          :username   => 'syalala',
          :email      => user.email,
          :bio        => user.bio
        }

        expect(UserController.edit(param)).to eq(true)
      end
    end
  end

  describe "#destroy" do
    context "when id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { UserController.destroy(id) }.to raise_error("User with id #{id} not found")
      end
    end

    context "when id exist" do
      it 'should raise an error' do
        id = User.get_last_item.id
        expect(UserController.destroy(id)).to eq(true)
      end
    end
  end

  describe '#index' do
    context 'when there is no data in database' do
      it 'should return empty array' do
        expect(UserController.index).to eq([])
      end
    end

    context 'when there is several data from database' do
      it 'should return array of User instance' do
        user = User.new({
          :username => 'tasyaaa',
          :email    => 'tasya@mail.com'
        })
        user.save
        expect(UserController.index).to include(User)

        create_db_client(0).query("TRUNCATE TABLE users")
      end
    end
  end
end