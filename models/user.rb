require_relative '../db/mysql_connector'

class User

  attr_accessor :id, :username, :email, :bio, :created_at, :updated_at

  def initialize(param)
    @id         = param.key?(:id) ? param[:id] : nil
    @username   = param[:username]
    @email      = param[:email]
    @bio        = param.key?(:bio) ? param[:bio] : nil
    @created_at = param.key?(:created_at) ? param[:created_at] : nil
    @updated_at = param.key?(:updated_at) ? param[:updated_at] : nil
  end

  def save
    create_db_client.query(
      'INSERT INTO users (id, username, email, bio)' +
      'VALUES (' +
      'UUID(),' +
      "'#{username}'," +
      "'#{email}'," +
      "'#{bio}')"
    )

    true
  end

  def update
    create_db_client.query(
      'UPDATE users ' +
        'SET ' +
        "username = '#{username}'," +
        "email = '#{email}'," +
        "bio = '#{bio}'," +
        'updated_at = CURRENT_TIMESTAMP ' +
        "WHERE id = '#{id}'"
    )
    true
  end

  def delete
    create_db_client.query("DELETE FROM users WHERE id = '#{id}'")
    true
  end

  def exist?
    query = create_db_client.query("SELECT COUNT(*) as count FROM users WHERE username = '#{username}' OR email = '#{email}'")
    query.each {|data| return data['count'] >= 1}
  end

  def valid?
    return false if username.nil?
    return false if email.nil?
    true
  end

  def self.get_all_user
    db_raw = create_db_client.query("select * from users")

    users = Array.new

    db_raw.each do |data|
      user = User.new({
        :id         => data["id"],
        :username   => data["username"],
        :email      => data["email"],
        :bio        => data["bio"],
        :created_at => data["created_at"],
        :updated_at => data["updated_at"],
      })
      users.push(user)
    end

    users
  end

  def self.find_single_user(id)
    user = self.get_all_user.find{|x| x.id == id}

    if user.nil?
      raise "User with id #{id} not found"
    end

    user
  end

  def self.get_last_item
    user = self.get_all_user.max_by{|x| x.created_at}

    if user.nil?
      raise "There is no User"
    end

    user
  end
end