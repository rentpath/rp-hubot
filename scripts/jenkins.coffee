# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->
  
  startJenkinsJob = (job_name, res) ->
    request = robot.http("http://idg.automation:Rentpath12%21%21@jenkins-master-01.qa.atl.primedia.com/job/#{job_name}/build")
    request.header('Accept', 'application/json')
    data = JSON.stringify
      token: 'a3588d910f98ea6d07dae2c56b0d78a1'
    request.post(data) (err, response, body) ->
      try
        status_code = response.statusCode
        if status_code == 201
          res.send "Jenkins job #{job_name} has been successfully started."
        else
          res.send "There was an error starting Jenkins job #{job_name}. Received status code #{status_code}."
      catch error
        res.send "Ran into an error checking response code from Jenkins API response :( - #{error}"
        return
        
  robot.respond /build (.*)$/i, (res) ->
    job_name = res.match[1]
    res.send job_name
    startJenkinsJob job_name, res