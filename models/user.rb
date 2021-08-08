require_relative '../db/mysql_connector'

class User

  attr_accessor :id, :username, :email, :bio

  def initialize(param)
    @id         = param.key?(:id) ? param[:id] : nil
    @username   = param[:username]
    @email      = param[:email]
    @bio        = param.key?(:bio) ? param[:bio] : nil
  end

  def save
    create_db_client.query(
      'INSERT INTO users (id, username, email, bio)' +
      'VALUES (' +
      'UUID_TO_BIN(UUID()),' +
      "'#{username}'," +
      "'#{email}'," +
      "'#{bio}')"
    )

    true
  end

  def exist?
    query = create_db_client.query("SELECT COUNT(*) as count FROM users WHERE username = '#{username}' OR email = '#{email}'")
    query.nil?
  end

  def valid?
    return false if username.nil?
    return false if email.nil?
    true
  end

  def self.get_all_user
    db_raw = create_db_client.query("select * , BIN_TO_UUID(id) AS id from users")

    users = Array.new

    db_raw.each do |data|
      user = User.new({
        :id       => data["id"],
        :username => data["username"],
        :email    => data["email"],
        :bio      => data["bio"]
      })
      users.push(user)
    end

    users
  end
end