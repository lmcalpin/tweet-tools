def highlight(str, reversed)
  output = ""
  i = 0
  str.scan(/(\S*|\s*)/).each do |s|
    i += 1
    t = s.join(' ')
    if (/htt(p|ps):\/\/.*/ === t) then
      output << '<a href="' + t + '">' + t + '</a>'
    elsif (/@([A-Za-z0-9_]+)/ === t) then
      reversed_string = reversed ? '?dir=reversed' : ''
      match = t[/@([A-Za-z0-9_]+)/]
      username = match[1..match.length-1]
      url = "/timeline/#{username}#{reversed_string}"
      link = "<span class='twitter-ref'>@<a href='#{url}'>#{username}</a></span>"
      newstring = t.gsub(/@([A-Za-z0-9_]+)/, link)
      output << newstring
    elsif (t === '') then
      output << " "
    else
      output << t
    end
  end
  output
end
