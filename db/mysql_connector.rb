require 'mysql2'

def create_db_client(fk_check = 1)
  Mysql2::Client.new(
    :host         => ENV['DB_HOST'],
    :username     => ENV['DB_USERNAME'],
    :password     => ENV['DB_PASSWORD'],
    :database     => ENV['DB_NAME'],
    :init_command => "SET FOREIGN_KEY_CHECKS = #{fk_check}"
  )
end

