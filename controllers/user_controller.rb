require_relative '../models/user'

class UserController
  def self.index
    User.get_all_user
  end

  def self.create(params)
    user = User.new(params)

    return 'username or email already exist' if user.exist?
    return 'wrong parameter' unless user.valid?

    user.save
    return 'user created'
  end

  def self.edit(params)
    user = User.new(params)

    return 'wrong parameter' unless user.valid?
    user.update
    return 'user updated'
  end

  def self.destroy(id)
    user = User.find_single_user(id)

    user.delete
    return 'user deleted'
  end
end
