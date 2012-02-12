require 'rubygems'

require 'timeago'
require 'twitter'

# Users:
# location, description, followers_count, friends_count, statuses_count
class TweetQueryResponse
  attr_reader :timeline, :error
  def initialize(timeline, error)
    @timeline = timeline
    @error = error
  end 
  
  def reverse
    @timeline = @timeline.reverse
    self
  end
end

class Status
  attr_accessor :userid, :message, :created_at
  attr_reader :relative_timestamp
  def initialize(userid, message, created_at)
    @userid = userid
    @message = message
    @created_at = created_at
    @relative_timestamp = timeago(created_at)
  end
end

class TweetManager
  attr_reader :next_cursor, :next_idx
  def initialize(client, userid)
    @client = client
    @userid = userid
    @user = @client.user(userid)
  rescue => e
    @user = nil
  end
  
  def user
    return @user
  end
  
  def followers(cursor, next_idx)
    cursor = -1 if cursor.nil?
    next_idx = 0 if next_idx.nil?
    followers = []
    r = @client.follower_ids(:user =>@userid, :cursor=>cursor)
    lookup_users(r, next_idx.to_i) do |f|
      followers << f
    end
    followers.sort {|x,y| x.screen_name <=> y.screen_name }
  end
  
  def friends(cursor, next_idx)
    cursor = -1 if cursor.nil?
    next_idx = 0 if next_idx.nil?
    friends = []
    r = @client.friend_ids(:user =>@userid, :cursor=>cursor)
    lookup_users(r, next_idx.to_i) do |f|
      friends << f
    end
    friends.sort {|x,y| x.screen_name <=> y.screen_name }
  end
  
  def timeline
    statusentries = []
    @client.user_timeline(:user=>@userid, :count=>35).each do |status|
      statusentries << Status.new(status['screen_name'], status.text, status.created_at)
    end
    TweetQueryResponse.new(statusentries, false)
  rescue => e
    puts e.inspect
    puts e.backtrace
    TweetQueryResponse.new([], true)
  end
  
private
  def lookup_users(r, startidx, &blk)
    max = [r.ids.length, startidx + 100].max
    @next_idx = max
    @next_idx = -1 if max == r.ids.length
    @next_cursor = -1
    @next_cursor = r.next_cursor if not r.last?
    users = @client.users(r.ids.slice(startidx,max))
    users.each do |f|
      blk.call(f)
    end
  end 
  
end

