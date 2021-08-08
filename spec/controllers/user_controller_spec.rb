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
end