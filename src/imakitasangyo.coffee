# Description:
#   Utility commands surrounding Hubot uptime.
#
# Commands:
#
Promise = require("bluebird")

module.exports = (robot) ->
  robot.hear /^今北産業$/, (msg) ->
    room = msg.envelope.room
    if room == "Shell"
      room = "general"
      console.log "room: converted Shell -> #{room}"

    getChannelIDfromRoom(msg, room).then (ch_id) ->
      if ch_id != ""
        getRecentMessages(msg, ch_id).then (messages) ->
          if messages != []
            processMessages(msg, messages).then (messages_processed) ->
              if messages_processed != ""
                getSummary(msg, messages_processed).then (summary) ->
                  if summary != ""
                    msg.send summary


getRecentMessages = (msg, room_id) ->

  if room_id == ""
    return []

  url = 'https://slack.com/api/channels.history'
  query = {
    token: process.env.SLACK_TOKEN,
    channel: room_id,
    count: process.env.HUBOT_IMAKITASANGYO_SOURCE_LINES
  }

  getJSONResponseFromAPI_promised(msg, url, query).then (res) ->

    if(res.ok)
      return res.messages
    else
      console.log res
      msg.send "channel.historyの取得に失敗"
      return []
    return


getChannelIDfromRoom = (msg, room) ->
  if room == ""
    return ""
  url = 'https://slack.com/api/channels.list'
  query = {
      token: process.env.SLACK_TOKEN
    }

  getJSONResponseFromAPI_promised(msg, url, query).then (res) ->
    if (res.ok)
      for ch in res.channels
        if ch.name == room
          return ch.id
      msg.send "#{room}のchannel idが見つかりません"
    else
      console.log res
      msg.send "channels.listの取得に失敗"
      return ""
    return


processMessages = (msg, messages) ->

  if messages == []
    return ""

  texts = []
  userdict = {}

  url = "https://slack.com/api/users.list"
  query = {
    token: process.env.SLACK_TOKEN
  }

  getJSONResponseFromAPI_promised(msg, url, query).then (res) ->
    if(res.ok)
      for member in res.members
        userdict[member.id] = member.name

      for message in messages
        console.log message
        if message.type = "message" and !message.subtype and message.user != process.env.HUBOT_IMAKITASANGYO_BOT_USER_ID and message.text != "今北産業"
          text = message.text

          # remove newlines
          text = text.replace(/\n/g, "")

          # recover url
          text = text.replace(/<(https?|ftp)(:\/\/[-_.!~*\'()a-zA-Z0-9;\/?:\@&=+\$,%#]+)>/g, (match) -> return " #{match.slice(1,-1)} ")

          # recover @channel/@group
          text = text.replace(/<!channel>/g, "@channel")
          text = text.replace(/<!group>/g, "@group")

          # process username
          for member_id, member_name of userdict
            text = text.replace(///#{member_id}///g, "#{member_name}")

          # HACK: Add 。for tokenize
          texts.push(text)
      return texts.join('。')
    else
      console.log res
      msg.send "ユーザーリスト取得に失敗"


getSummary = (msg, text) ->

  if text == ""
    return ""

  url = process.env.HUBOT_IMAKITASANGYO_SUMMPY_API_URL
  query = {
      text: text,
      sent_limit: 3
    }

  getJSONResponseFromAPI_promised(msg, url, query).then (res) ->
    if (res.summary)
      return res.summary.join('\n')
    else
      console.log res
      msg.send "summpy APIが動いていないかエラーが出ています"
      return ""


getJSONResponseFromAPI_promised = (msg, url, query) ->
  console.log "-----getJSONResponseFromAPI_promised-----"
  console.log "url:#{url}"
  console.log "query:"
  console.log query
  console.log "-----------------------------------------"

  return new Promise (resolve, reject) ->
    msg.http(url)
      .query(query)
      .get() (err, res, body) ->
        if err
          reject err
        else
          resolve JSON.parse(body)