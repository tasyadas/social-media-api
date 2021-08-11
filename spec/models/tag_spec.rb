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

  describe "#find_single_tag" do
    context "when id doesn't exist" do
      it 'should raise an error' do
        id = '1'
        expect { Tag.find_single_tag(id) }.to raise_error("Tag with id #{id} not found")
      end
    end

    context "when id exist" do
      it 'should return hash of Tag model' do
        id = Tag.get_last_item.id
        expect(Tag.find_single_tag(id)).to be_a(Tag)
      end
    end
  end
end
