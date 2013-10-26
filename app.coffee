request = require 'request'
fs = require 'fs'
config = JSON.parse fs.readFileSync('config.json', encoding: 'utf8')



# make sure to persist our logs.
logger = (err) ->
  console.error err
  fs.appendFileSync('log.txt', '\n' + JSON.stringify(err, false, 2) + '\n' )



# make sure the error log isn't getting enormous.
loglimit = 30
logDate = new Date(config.lastLogClean)
logDate.setDate(logDate.getDate()+30)

if Date.now() > logDate
  config.lastLogClean = Date.now()
  fs.writeFileSync 'log.txt', ''
  fs.writeFileSync 'config.json', JSON.stringify(config, false, 2)
  logger 'Cleaned logs on ' + config.lastLogClean



# find out our current external address.
request 'http://icanhazip.com', (err, res, theIP) ->
  # handle any http error like a bad connection.
  if err
    logger err
    process.exit()

  # regex checks that it's a standard IP address within normal range.
  IPRegex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  theIP = theIP.trim()

  # make sure we got a proper IP response back.
  if IPRegex.test(theIP) == false
    logger 'icanhazip did not return a valid IP address.'
    process.exit()

  # most likely scenario: the IP is the same so just kill the process.
  if theIP == config.currentIP
    console.log 'IP is still the same.'
    process.exit()

  config.currentIP = theIP
  fs.writeFileSync 'config.json', JSON.stringify(config, false, 2)



  # set the new IP address for each record.
  config.domains.forEach (d, index, arr) ->
    request {
      url: 'https://dnsimple.com/domains/' + d.domain + '/records/' + d.record
      method: 'PUT'
      headers:
        'X-DNSimple-Domain-Token': d.token
        'Accept': 'application/json'
        'Content-Type': 'application/json'
      json: { record: { content: theIP } }

    }, (err, res, resBody) ->
      if err
        logger 'Failed to update dnsimple.'
      console.log 'Updated ' + d.domain + ' successfully.'
