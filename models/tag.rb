require_relative '../db/mysql_connector'

class Tag

  attr_accessor :id, :name, :tweets, :comments

  def initialize(param)
    @id        = param.key?(:id) ? param[:id] : nil
    @name      = param[:name]
    @tweets    = param.key?(:tweets) ? param[:tweets] : []
    @comments  = param.key?(:comments) ? param[:comments] : []
  end

  def save
    create_db_client.query(
      'INSERT INTO tags ' +
      '(id, name)' +
      'VALUES ( ' +
        'UUID(), ' +
        "'#{name}'" +
      ')'
    )

    true
  end
end
