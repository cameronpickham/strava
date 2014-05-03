request = require 'request'
async   = require 'async'

{ accessToken }  = require './config'

activitiesOpts =
  uri: 'https://www.strava.com/api/v3/athlete/activities'
  qs:
    access_token: accessToken

request activitiesOpts, (err, req, body) ->
  activityIds = JSON.parse(body).map((e) -> e.id)

  mapper = (activityId, cb) ->
    streamOpts =
      uri: "https://www.strava.com/api/v3/activities/#{activityId}/streams/latlng"
      qs:
        access_token: accessToken
        resolution:   'high'

    request streamOpts, (err, req, body) ->
      return cb(err) if err
      body = JSON.parse(body)

      # For some reason they're giving me distance and latlng instead of just latlng
      latlng = {}
      if body instanceof Array
        for result in body
          if result.type is 'latlng'
            latlng = result
            break
      else
        latlng = body
      
      cb(null, latlng)

  async.map activityIds, mapper, (err, results) ->
    return console.log err if err
    console.log results
