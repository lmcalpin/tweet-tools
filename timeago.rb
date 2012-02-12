require 'time'

def timeago(time, options = {})
  start_date = options.delete(:start_date) || Time.new
  post_date = Time.parse(time.to_s)
  date_format = options.delete(:date_format) || :default
  delta_minutes = (start_date.to_i - post_date.to_i).floor / 60
  if delta_minutes.abs <= (8724*60)
    distance = distance_of_time_in_words(delta_minutes)
    if delta_minutes < 0
      return "#{distance} from now"
    else
      return "#{distance} ago"
    end
  else
    return "on #{post_date.strftime("%B %d, %Y")} at #{post_date.strftime("%I:%M:%S %p")}"
  end
end

def distance_of_time_in_words(minutes)
  case
  when minutes < 1
    "less than a minute"
  when minutes < 50
    pluralize(minutes, "minute", "minutes")
  when minutes < 90
    "about one hour"
  when minutes < 1080
    "#{(minutes / 60).round} hours"
  when minutes < 1440
    "one day"
  when minutes < 2880
    "about one day"
  else
    "#{(minutes / 1440).round} days"
  end
end

def pluralize(amount, singular, plural)
  amount == 1 ? singular : plural
end