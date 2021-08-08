require_relative '../models/user'

class UserController
  def self.create(params)
    user = User.new(params)

    return 'username or email already exist' if user.exist?
    return 'wrong parameter' unless user.valid?

    user.save
  end

  def self.edit(params)
    user = User.new(params)

    return 'wrong parameter' unless user.valid?
    user.update
  end
end
