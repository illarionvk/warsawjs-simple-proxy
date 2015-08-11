'use strict'

url = require('url')
Wreck = require('wreck')
Hapi = require('hapi')

getInstagram = (next) ->
  clientID = process.env.INSTAGRAM_CLIENT_ID || ''
  instagramURL = [
    'https://api.instagram.com/v1/users/234016235/media/recent'
    "?client_id=#{clientID}"
    '&count=12'
  ].join('')

  Wreck.get(
    instagramURL
    null
    (err, res, payload) ->
      console.log 'Getting Instagram data...'
      if err
        return next(err)
      if res.statusCode != 200
        return next(res.statusCode)
      return next(null, JSON.parse(payload))
  )
  return

server = new Hapi.Server()

server.connection({
  port: process.env.PORT || 3000
})

server.method(
  'getInstagram'
  getInstagram
  {
    cache:
      expiresIn: 60 * 60 * 1000 # one hour
      staleIn: 60 * 1000 # one minute
      staleTimeout: 100
  }
)

server.route({
  method: 'GET'
  path: '/instagram.json'
  handler: (request, reply) ->
    server.methods.getInstagram( (error, result) ->
      if error
        return reply({
          error: error
        }).code(500)
      return reply(result)
    )
  config:
    cors: true
    cache:
      expiresIn: 60 * 60 * 1000 # one hour
      privacy: 'private'
})

server.start( ->
  console.log(
    'Server running at:'
    server.info.uri
  )
)

