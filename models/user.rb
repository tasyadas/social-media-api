require_relative '../db/mysql_connector'

class User

  attr_accessor :id, :username, :email, :bio

  def initialize(param)
    @id         = param.key?(:id) ? param[:id] : nil
    @username   = param[:username]
    @email      = param[:email]
    @bio        = param.key?(:bio) ? param[:bio] : nil
  end

  def exist?
    query = create_db_client.query("SELECT COUNT(*) FROM users WHERE username = #{@username} OR email = #{@email}")
    query.nil?
  end

  def valid?
    return false if @username.nil?
    return false if @email.nil?
    true
  end
end