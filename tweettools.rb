# http://tweettools.heroku.com/ | git@heroku.com:tweettools.git
require 'rubygems'
require 'erb'
require_relative 'highlight'
require 'sinatra'
require 'sinatra/flash'
require 'oauth'
require 'oauth/consumer'
require 'twitter'
require_relative 'tweetmanager'

enable :sessions

REQUEST_TOKEN_URL = "https://twitter.com/oauth/request_token"
ACCESS_TOKEN_URL = "https://twitter.com/oauth/access_token"
AUTHORIZE_URL = "https://twitter.com/oauth/authorize"
CONSUMER_KEY    = ENV['TWITTER_KEY']
CONSUMER_SECRET = ENV['TWITTER_SECRET']

configure(:development) do |c|
  require "sinatra/reloader"
  c.also_reload "*.rb"
end

before do
  session[:oauth] ||= {}

  @consumer ||= OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, :site => "http://twitter.com")

  unless session[:oauth][:request_token].nil? || session[:oauth][:request_token_secret].nil?
    @request_token = OAuth::RequestToken.new(@consumer, session[:oauth][:request_token], session[:oauth][:request_token_secret])
  end

  unless session[:oauth][:access_token].nil? || session[:oauth][:access_token_secret].nil?
    @access_token = OAuth::AccessToken.new(@consumer, session[:oauth][:access_token], session[:oauth][:access_token_secret])
  end

  if @access_token
    Twitter.configure do |config|
      config.consumer_key       = CONSUMER_KEY
      config.consumer_secret    = CONSUMER_SECRET
      config.oauth_token        = @access_token.token
      config.oauth_token_secret = @access_token.secret
    end
    @client = Twitter::Client.new
  end
end

post '/' do
  postview = @params['view']
  unless postview.nil?
    @username = @params['userid']
    @url = '/timeline/' + @username
    redirect @url
  end
  postview = @params['reversed']
  unless postview.nil?
    @username = @params['userid']
    @url = '/timeline/' + @username + '?dir=reversed'
    redirect @url
  end
  redirect '/'
end

get '/' do
  erb :index
end

get '/timeline/' do
  flash[:error] = "Did you forget to type?"
  redirect '/'
end

get '/timeline/:user' do |user|
  redirect '/' unless @access_token
  @reversed = (request[:dir] == "reversed")
  @manager = TweetManager.new(@client, user)
  if (@manager.user.nil?) then
    flash[:error] = "Error looking up #{user}."
    redirect '/'
  end
  @user = @manager.user
  @twitter_response = @reversed ? @manager.timeline.reverse : @manager.timeline
  erb :timeline
end

get '/followers/:user' do |user|
  redirect '/' unless @access_token
  @cursor = request[:cursor]
  @next_idx = request[:idx]
  @manager = TweetManager.new(@client, user)
  if (@manager.user.nil?) then
    flash[:error] = "Error looking up #{user}."
    redirect '/'
  end
  @user = @manager.user
  @followers = @manager.followers(@cursor, @next_idx)
  @next_cursor = @manager.next_cursor
  @next_idx = @manager.next_idx
  erb :followers
end

get '/friends/:user' do |user|
  redirect '/' unless @access_token
  @cursor = request[:cursor]
  @next_idx = request[:idx]
  @manager = TweetManager.new(@client, user)
  if (@manager.user.nil?) then
    flash[:error] = "Error looking up #{user}."
    redirect '/'
  end
  @user = @manager.user
  @friends = @manager.friends(@cursor, @next_idx)
  @next_cursor = @manager.next_cursor
  @next_idx = @manager.next_idx
  erb :friends
end

get "/request" do
  @host = request.host
  @host << ":4567" if request.host == "localhost"
  puts "host is #{request.host}, #{@host}"
  @request_token = @consumer.get_request_token(:oauth_callback => "http://#{@host}/auth")
  session[:oauth][:request_token] = @request_token.token
  session[:oauth][:request_token_secret] = @request_token.secret
  redirect @request_token.authorize_url
end

get "/auth" do
  @access_token = @request_token.get_access_token :oauth_verifier => params[:oauth_verifier]
  session[:oauth][:access_token] = @access_token.token
  session[:oauth][:access_token_secret] = @access_token.secret
  redirect "/"
end

get "/logout" do
  session[:oauth] = {}
  redirect "/"
end
