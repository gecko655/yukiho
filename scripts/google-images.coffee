# Description:
#   A way to interact with the Google Images API.
#
# Commands:
#   hubot image me <query> - The Original. Queries Google Images for <query> and returns a random top result.
#   hubot animate me <query> - The same thing as `image me`, except adds a few parameters to try to return an animated GIF instead.
#   hubot mustache me <url> - Adds a mustache to the specified URL.
#   hubot mustache me <query> - Searches Google Images for the specified query and mustaches it.
#   ラブライブ - Getting lovelive gif. This is a alias of `hubot animate me ラブライブ`.

module.exports = (robot) ->
  robot.respond /(image|img)( me)? (.*)/i, (msg) ->
    imageMe msg, msg.match[3], (url) ->
      msg.send url

  robot.respond /animate( me)? (.*)/i, (msg) ->
    imageMe msg, msg.match[2], true, (url) ->
      msg.send url

  robot.respond /(?:mo?u)?sta(?:s|c)he?(?: me)? (.*)/i, (msg) ->
    type = Math.floor(Math.random() * 6)
    mustachify = "http://mustachify.me/#{type}?src="
    imagery = msg.match[1]

    if imagery.match /^https?:\/\//i
      msg.send "#{mustachify}#{imagery}"
    else
      imageMe msg, imagery, false, true, (url) ->
        msg.send "#{mustachify}#{url}"

  robot.hear /ラブライブ/i, (msg) ->
    imageMe msg, "ラブライブ", true, (url) ->
      msg.send url

imageMe = (msg, query, animated, faces, cb) ->
  randomInt = Math.floor(Math.random()*100)+1
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  q = key: process.env.HUBOT_GOOGLE_SEARCH_KEY, cx: process.env.HUBOT_GOOGLE_SEARCH_CX , start : randomInt, num : 1, searchType: 'image', q: query, safe: 'medium', fileType: 'gif'
  q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
  q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
  msg.http('https://www.googleapis.com/customsearch/v1')
    .query(q)
    .get() (err, res, body) ->
      results = JSON.parse(body)
      images = results.items
      if images?.length > 0
        image  = msg.random images
        cb "#{image.link}#.png"
