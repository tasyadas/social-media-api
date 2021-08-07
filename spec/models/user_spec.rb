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
end