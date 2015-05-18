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

  getGituhbIssues = (username, project, res) ->
    request = robot.http("https://api.github.com/repos/rentpath/#{project}/issues?access_token=59f0041f390f38b1daec128dbd8f79155ae6c769&assignee=#{username}")
    request.get() (err, response, body) ->
      try
        data = JSON.parse(body)
        if data and data.length > 0
          parseIssuesAndNotifyRoom data, username, res
        else
          res.send "There are no issues / pull requests assigned to you in the #{project} repo at this time."
      catch error
        res.send "Ran into an error parsing JSON for asignee request :( - #{error}"
        return

  parseIssuesAndNotifyRoom = (issues, username, project, res) ->
    message = "Issues / Pull Reqeusts assigned to user #{username} for #{project}:\n\n"
    for issue in issues
      title = issue.title
      url = issue.html_url
      message += "#{title} \n #{url} \n\n"

    res.send message

  robot.respond /issues assigned to (.*)$/i, (res) ->
    username = res.match[1]
    getGituhbIssues username, "ios_apartmentguide", res
    getGituhbIssues username, "Bishop", res
    getGituhbIssues username, "ios_maxleases", res
    getGituhbIssues username, "android_maxleases", res
    