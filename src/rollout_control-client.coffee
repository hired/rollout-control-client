RolloutControl = {}

module.exports = RolloutControl

request = require 'superagent'
{Promise} = require 'rsvp'

class RolloutControl.Client
  constructor: (@url, @username, @password) ->

  formatError: (res) ->
    message: res.text
    unauthorized: res.unauthorized
    status: res.status
    statusType: res.statusType

  apiRequest: (method, path, data) ->
    url = "#{@url.replace(/\/$/, '')}#{path}"
    req = request(method, url)
    if @username
      req.set('Authorization', "Basic #{new Buffer("#{@username}:#{@password}").toString('base64')}")
    req.set('Accept', 'application/json') if method == 'GET'
    req.set('Content-Type', 'application/json') if method == 'POST' or method == 'PATCH'
    req.send(data) if data

    new Promise (done, fail) =>
      req.end (res) =>
        if res.ok then done res.body
        else fail @formatError(res)

  list: ->
    @apiRequest('GET', '/features')

  get: (featureName) ->
    @apiRequest('GET', "/features/#{featureName}")

  activate: (featureName) ->
    @apiRequest('PATCH', "/features/#{featureName}", { percentage: 100 })

  deactivate: (featureName) ->
    @apiRequest('PATCH', "/features/#{featureName}", { percentage: 0 })

  activatePercentage: (featureName, percentage) ->
    @apiRequest('PATCH', "/features/#{featureName}", { percentage: percentage })

  activateGroup: (featureName, group) ->
    @apiRequest('POST', "/features/#{featureName}/groups", { group: group })

  deactivateGroup: (featureName, group) ->
    @apiRequest('DELETE', "/features/#{featureName}/groups/#{group}")

  activateUser: (featureName, userId) ->
    @apiRequest('POST', "/features/#{featureName}/users", { user_id: userId })

  deactivateUser: (featureName, userId) ->
    @apiRequest('DELETE', "/features/#{featureName}/users/#{userId}")
