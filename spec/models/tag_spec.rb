require_relative '../../models/tag'

describe Tag do
  describe "#save" do
    context "when given valid params" do
      it 'should return true' do
        tag = Tag.new({
          :name => 'GenerasiGigih',
        })

        mock_client = double
        allow(Mysql2::Client).to receive(:new).and_return(mock_client)
        expect(mock_client).to receive(:query).with(
          'INSERT INTO tags ' +
          '(id, name)' +
          'VALUES ( ' +
            'UUID(), ' +
            "'#{tag.name}'" +
          ')'
        )

        expect(tag.save).to eq(true)
      end
    end
  end
end
