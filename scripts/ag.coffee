# Description
#   Display version tags and asset fingerprints for all AG prod servers.
#   Useful for ensuring prod matches QA.
#
# Dependencies:
#   "q": "^1.0.1"
#   "request": "^2.40.0",
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot smoketest ag - Show version tags and asset fingerprints for AG prod.
#
# Notes:
#   Requires VPN access
#
# Author:
#   c0

Q       = require 'q'
request = Q.denodeify require('request')
util    = require 'util'

servers     = [1..10]
dataCenters = ['atl', 'lax']

assetFilenames = [
  'application.css'
  'main-dist.js'
]
qa = 'www.qa.apartmentguide.com/'

domain = (num, dataCenter) ->
  num = "0#{num}" if num < 10
  "ag-web-#{num}.#{dataCenter}.primedia.com"

url = (num, dataCenter) ->
  "http://#{domain(num, dataCenter)}/ops/version.json"

getVersion = (num, dataCenter) ->
  response = request
    uri:     url(num, dataCenter)
    method: 'GET'
  response.then (res) ->
    if (res.statusCode >= 300)
      throw new Error('Server responded with status code ' + res.statusCode)
    else
      data = JSON.parse(res[0].body.toString())
      "#{domain(num, dataCenter)}: #{data.version}"

mappedUrls = []
dataCenters.forEach (name) ->
  for num in servers
    mappedUrls.push getVersion(num, name)

getAssetFingerprint = (filename, domain) ->
  [base, ext] = filename.split('.')
  response = request
    uri:     "http://#{domain}"
    method: 'GET'
  response.then (res) ->
    if (res.statusCode >= 300)
      throw new Error('Server responded with status code ' + res.statusCode)
    else
      body = res[0].body.toString()
      regex = new RegExp("#{base}-([A-Z0-9]+).#{ext}", "i")
      fingerprint = body.match(regex)[1]
      "#{domain}: #{filename}: #{fingerprint}"

mappedFingerPrints = []

assetFilenames.forEach (assetFilename) ->
  mappedFingerPrints.push getAssetFingerprint(assetFilename, qa)
  dataCenters.forEach (name) ->
    for num in servers
      mappedFingerPrints.push getAssetFingerprint(assetFilename, domain(num, name))

module.exports = (robot) ->

  robot.respond /smoketest ag/i, (msg) ->
    msg.send "Smoke Testing AG"
    Q
      .all(mappedUrls)
      .then (versions) ->
        versions.forEach (version) ->
          robot.emit version
    Q
      .all(mappedFingerPrints)
      .then (assets) ->
        assets.forEach (asset) ->
          robot.emit asset

  robot.on 'debug', (event) ->
    robot.send event.user, util.inspect event
