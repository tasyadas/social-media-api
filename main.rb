require 'sinatra'
require 'oj'

require_relative './controllers/user_controller'
require_relative './controllers/tweet_controller'
require_relative './controllers/comment_controller'
require_relative './controllers/tag_controller'

set :public_folder, 'public/uploads'

# start user route
get '/users' do
  content_type :json
  Oj.dump(UserController.index, { :time_format => :ruby })
end

post '/users' do
  content_type :json
  Oj.dump(UserController.create(params), { :time_format => :ruby })
end

patch '/users/:id' do
  content_type :json
  puts params
  Oj.dump(UserController.edit(params), { :time_format => :ruby })
end

delete '/users/:id' do |id|
  content_type :json
  Oj.dump(UserController.destroy(id), { :time_format => :ruby })
end
# end user route


# tweet route
get '/tweets' do
  content_type :json
  Oj.dump(TweetController.index, { :time_format => :ruby })
end

post '/tweets' do
  content_type :json
  Oj.dump(TweetController.create(params))
end
# end tweet route


# comment route
get '/comments' do
  content_type :json
  Oj.dump(CommentController.index, { :time_format => :ruby })
end

post '/comments' do
  content_type :json
  Oj.dump(CommentController.create(params))
end
# end comment route


# tag route
get '/hashtag-filter/:tag' do |tag|
  content_type :json
  Oj.dump(TagController.filter_by_hashtag(tag), { :time_format => :ruby })
end

get '/trending-hashtag' do
  content_type :json
  Oj.dump(TagController.get_five_trending, { :time_format => :ruby })
end
# end comment route