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
  
  pivotal_api_key = '46682d4fd542be3a3951cf5679394888'

  getIterationData = (project_id, scope, res, callback) ->
    url = "https://www.pivotaltracker.com/services/v5/projects/#{project_id}/iterations?scope=#{scope}"
    request = robot.http(url)
    request.header('Accept', 'application/json')
    request.header('X-TrackerToken', pivotal_api_key)
    request.get() (err, response, body) ->
      
      if err
        res.send "Encountered an error :( #{err}"
        return
      
      if typeof response is 'undefined'
        res.send "Response was undefied :("
        return
        
      if response.statusCode isnt 200
        res.send "Request didn't come back HTTP 200 :("
        return
		
      if typeof body is 'undefined'
        res.send "Body was undefied :("
        return
      
      data = null
      try
        data = JSON.parse(body)
        if data is null
          res.send "Data is null :("
          return
        callback data
      catch error
        res.send "Ran into an error parsing iteration JSON :( - #{error}"
        return
        
  parseIterationDataAndPostMessage = (data, res) ->
    current = data[0]
    number_of_stories = 0
    total_points = 0
    completed_points = 0
    
    accepted_stories = []
    accepted_points = 0
    
    delivered_stories = []
    delivered_points = 0
    
    finished_stories = []
    finished_points = 0
    
    started_stories = []
    started_points = 0
    
    unstarted_stories = []
    unstarted_points = 0
    
    restarted_stories = []
    restarted_points = 0
    
    feature_stories = 0
    bug_stories = 0
    chore_stories = 0
    
    for story in current.stories
      
      continue unless story.estimate?
      
      number_of_stories += 1
      total_points      += story.estimate
      completed_points  += story.estimate if story.current_state is 'accepted'
        
      if story.current_state is 'accepted'
        accepted_stories.push story
        accepted_points += story.estimate
      
      if story.current_state is 'delivered'
        delivered_stories.push story
        delivered_points += story.estimate
        
      if story.current_state is 'finished'
        finished_stories.push story
        finished_points += story.estimate
      
      if story.current_state is 'started'
        started_stories.push story
        started_points += story.estimate
      
      if story.current_state is 'unstarted'
        unstarted_stories.push story
        unstarted_points += story.estimate
      
      if story.current_state is 'rejected'
        restarted_stories.push story
        restarted_points += story.estimate
      
      feature_stories += 1 if story.story_type is 'feature'
      bug_stories += 1 if story.story_type is 'bug'
      chore_stories += 1 if story.story_type is 'chore'
    
    accepted_percentage = Math.round((completed_points * 100) / total_points)
    
    res.send "/quote Current iteration is ##{current.number}\n\n" +

    "// Sprint Overview / Completion ---------------------\n" +
    "[#{number_of_stories}] Stories worth [#{total_points}] points\n" +
    "[#{accepted_stories.length}] Completed Stories worth [#{completed_points}] points\n" +
    "This sprint is #{accepted_percentage}% completed\n\n" +
    
    "// Story Statuses -----------------------------------\n" +
    "[#{delivered_stories.length}] Delivered Stories worth [#{delivered_points}] points\n" +
    "[#{finished_stories.length}] Finished Stories worth [#{finished_points}] points\n" +
    "[#{started_stories.length}] Started Stories worth [#{started_points}] points\n" +
    "[#{unstarted_stories.length}] Unstarted Stories worth [#{unstarted_points}] points\n" +
    "[#{restarted_stories.length}] Restarted Stories worth [#{restarted_points}] points\n\n" +
    
    "// Story Types --------------------------------------\n" +
    "[#{feature_stories}] Feature Stories\n" +
    "[#{bug_stories}] Bug Stories\n" +
    "[#{chore_stories}] Chore Stories"      
  
  getStoryDetails = (project_id, stories, res) ->
    fields = "&fields=url,name,description,story_type,estimate,current_state,requested_by,owned_by,labels,deadline"
    path = "/projects/#{project_id}/stories?filter=id%3A"
    for story in stories
      path += "#{story.id}%2C"
    host = "https://www.pivotaltracker.com/services/v5"
    url = host + path + fields
    request = robot.http(url)
    request.header('Accept', 'application/json')
    request.header('X-TrackerToken', pivotal_api_key)
    request.get() (err, response, body) ->
      data = null
      try
        data = JSON.parse(body)
        if data
          story_count = 0
          
          accepted_points = 0
          accepted_stories = []
          
          delivered_points = 0
          delivered_stories = []
          
          finished_points = 0
          finished_stories = []
          
          started_points = 0
          started_stories = []
          
          unstarted_points = 0
          unstarted_stories = []
          
          restarted_points = 0
          restarted_stories = []
          
          total_points = 0
          
          for story in data
            owner = story.owned_by
            if owner instanceof Array
              res.send "owned_by is and Array!"
            if typeof owner is 'undefined'
              continue
            owner_name = owner.name
            if owner_name == res.envelope.user.name
              story_count       += 1
              total_points      += story.estimate
              
              if story.current_state is 'accepted'
                accepted_points += story.estimate
                accepted_stories.push story
              
              if story.current_state is 'delivered'
                delivered_points  += story.estimate
                delivered_stories.push story
              
              if story.current_state is 'finished'
                finished_points   += story.estimate
                finished_stories.push story
              
              if story.current_state is 'started'
                started_points    += story.estimate
                started_stories.push story
              
              if story.current_state is 'unstarted'
                unstarted_points  += story.estimate
                unstarted_stories.push story
              
              if story.current_state is 'rejected'
                restarted_points  += story.estimate
                restarted_stories.push story
          
          if accepted_stories.length == 0 and delivered_stories.length == 0 and finished_stories.length == 0 and restarted_stories.length == 0 and started_stories.length == 0 and unstarted_stories.length == 0
            return
          
          stories_message = ""
          
          if delivered_stories.length > 0
            stories_message += "[#{delivered_stories.length}] Stories [#{delivered_points}] points pending Product pcceptance: \n"
            for story in delivered_stories
              if story.current_state is 'delivered'
                stories_message += "[#{story.id}] [#{story.estimate}] #{story.name}\n"
            stories_message += "\n"
          
          if finished_stories.length > 0    
            stories_message += "[#{finished_stories.length}] Stories [#{finished_points}] points pending QA pcceptance: \n"
            for story in finished_stories
              if story.current_state is 'finished'
                stories_message += "[#{story.id}] [#{story.estimate}] #{story.name}\n"
            stories_message += "\n"
            
          if restarted_stories.length > 0
            stories_message += "[#{restarted_stories.length}] Stories [#{restarted_points}] points waiting to be re-started: \n"
            for story in restarted_stories
              if story.current_state is 'rejected'
                stories_message += "[#{story.id}] [#{story.estimate}] #{story.name}\n"
            stories_message += "\n"
            
          if started_stories.length > 0
            stories_message += "[#{started_stories.length}] Stories [#{started_points}] points started: \n"
            for story in started_stories
              if story.current_state is 'started'
                stories_message += "[#{story.id}] [#{story.estimate}] #{story.name}\n"
            stories_message += "\n"
            
          if unstarted_stories.length > 0
            stories_message += "[#{unstarted_stories.length}] Stories [#{unstarted_points}] points unstarted: \n" 
            for story in unstarted_stories
              if story.current_state is 'unstarted'
                stories_message += "[#{story.id}] [#{story.estimate}] #{story.name}\n"
            stories_message += "\n"
          
          accepted_percentage = Math.round((accepted_points * 100) / total_points)
          
          getProjectDetails project_id, res, (data) ->
            res.send "/quote Here is the #{data.name} information for #{res.envelope.user.name}\n\n" +
            stories_message + 
            "Summary:\n" +
            "Total Story Points: #{total_points}\n" +
            "Accepted Story Points: #{accepted_points} (#{accepted_percentage}%)\n" +
            "Accepted Stories: #{accepted_stories.length}\n" +
            "Delivered Stories: #{delivered_stories.length}\n" +
            "Finished Stories: #{finished_stories.length}\n" +
            "Started Stories: #{started_stories.length}\n" +
            "Unstarted Stories: #{unstarted_stories.length}\n" +
            "Restarted Stories: #{restarted_stories.length}\n"
              
        else
          res.send "You have no stories assigned to you."
      catch error
        res.send "Ran into an error parsing story details JSON :( - #{error}"
        return
        
  getQAStories = (project_id, stories, res) ->
    fields = "&fields=url,name,description,story_type,estimate,current_state,requested_by,owned_by,labels,deadline"
    path = "/projects/#{project_id}/stories?filter=id%3A"
    for story in stories
      path += "#{story.id}%2C"
    host = "https://www.pivotaltracker.com/services/v5"
    url = host + path + fields
    request = robot.http(url)
    request.header('Accept', 'application/json')
    request.header('X-TrackerToken', pivotal_api_key)
    request.get() (err, response, body) ->
      data = null
      try
        data = JSON.parse(body)
        if data and data.length > 0
          stories_message = ""
          count = 0
          for story in data
            if story.current_state is 'finished'
              count += 1
              stories_message += "[#{story.id}] [#{story.estimate}] #{story.name} \n #{story.url} \n\n"
          
          getProjectDetails project_id, res, (data) ->
            res.send "There are #{count} stories awaiting QA acceptance in #{data.name}.\n\n" +
            stories_message
              
        else
          res.send "There are 0 stories awaiting QA acceptance."
      catch error
        res.send "Ran into an error parsing QA story details JSON :( - #{error}"
        return
        
  getProductStories = (project_id, stories, res) ->
    fields = "&fields=url,name,description,story_type,estimate,current_state,requested_by,owned_by,labels,deadline"
    path = "/projects/#{project_id}/stories?filter=id%3A"
    for story in stories
      path += "#{story.id}%2C"
    host = "https://www.pivotaltracker.com/services/v5"
    url = host + path + fields
    request = robot.http(url)
    request.header('Accept', 'application/json')
    request.header('X-TrackerToken', pivotal_api_key)
    request.get() (err, response, body) ->
      data = null
      try
        data = JSON.parse(body)
        if data and data.length > 0
          stories_message = ""
          count = 0
          for story in data
            if story.current_state is 'delivered'
              count += 1
              stories_message += "[#{story.id}] [#{story.estimate}] #{story.name} \n #{story.url} \n\n"
          
          getProjectDetails project_id, res, (data) ->
            res.send "There are #{count} stories awaiting Product acceptance in #{data.name}.\n\n" +
            stories_message
              
        else
          res.send "There are 0 stories awaiting Product acceptance."
      catch error
        res.send "Ran into an error parsing Product story details JSON :( - #{error}"
        return
        
  getUnestimatedStories = (project_id, res) ->
    url = "https://www.pivotaltracker.com/services/v5/projects/#{project_id}/stories?&with_state=unstarted&limit=100"
    request = robot.http(url)
    request.header('Accept', 'application/json')
    request.header('X-TrackerToken', pivotal_api_key)
    request.get() (err, response, body) ->
      
      if err
        res.send "Encountered an error :( #{err}"
        return
      
      if typeof response is 'undefined'
        res.send "Response was undefied :("
        return
        
      if response.statusCode isnt 200
        res.send "Request didn't come back HTTP 200 :("
        return
		
      if typeof body is 'undefined'
        res.send "Body was undefied :("
        return
      
      try
        data = JSON.parse(body)
        if data is null
          res.send "Data is null :("
          return
  
        stories_message = ""
        count = 0
        for story in data
          if typeof story.estimate is 'undefined'
            count += 1
            stories_message += "[#{story.id}] #{story.name} \n #{story.url} \n\n"
  
        getProjectDetails project_id, res, (data) ->
          res.send "There are #{count} stories ready for estimation in #{data.name}.\n\n" +
          stories_message
        
      catch error
        res.send "Ran into an error parsing unestimated story details JSON :( - #{error}"
        return
        
  getProjectDetails = (project_id, res, callback) ->
    request = robot.http("https://www.pivotaltracker.com/services/v5/projects/#{project_id}")
    request.header('Accept', 'application/json')
    request.header('X-TrackerToken', pivotal_api_key)
    request.get() (err, response, body) ->
      try
        data = JSON.parse(body)
        if data
          callback data
      catch error
        res.send "Ran into an error parsing JSON for /projects/<project-id> request :( - #{error}"
        return
        
  # Github Requests
  
  getGituhbIssues = (project, res, username = "") ->
    url_string = "https://api.github.com/repos/rentpath/#{project}/issues?access_token=59f0041f390f38b1daec128dbd8f79155ae6c769"
    url_string += "&assignee=#{username}" if !!username
    request = robot.http(url_string)
    request.get() (err, response, body) ->
      try
        data = JSON.parse(body)
        if data and data.length > 0
          parseIssuesAndNotifyRoom data, project, res, username
      catch error
        res.send "Ran into an error parsing JSON for github request :( - #{error}"
        return

  parseIssuesAndNotifyRoom = (issues, project, res, username = "") ->
    message = ""
    
    try
      if !!username
        message = "Issues / Pull Requests assigned to #{username} for #{project}:\n\n"
      else
        message = "Issues / Pull Requests for #{project}:\n\n"
      
      for issue in issues
        date = new Date(issue.created_at)
        title = issue.title
        url = issue.html_url
        created_by = issue.user.login
        assigned_to = if issue.assignee and issue.assignee.login then issue.assignee.login else "Unassigned"
        message += "#{title} \n #{url} \n Created By: #{created_by} \n Assigned To: #{assigned_to} \n Created On: #{date} \n\n"
    catch error
      res.send "Ran into an error parsing JSON for github response :( - #{error}"
      return

    res.send message
    
  getGithubUsername = (hipchat_name) ->
    user_map =
      "Johnny Moralez": "moralez"
      "Andre Leite": "aleite"
      "Jeremy Fox": "atljeremy"
      "Michael Lese": "mLese"
      "Chris Rebel": "chrisrebel"
      "Beth Moote": "BethMoote"
      "Ali Illyas": "aliillyas"
      "Garrett Franks": "aliillyas"
      "Bobby Williams": "bobjustbob"
      "Reginald Graham": "rgraham1984"
      "Allison Lizza": "allisonlizza"
      "Joseph Peters": "josephpeters"
      "Andres Cubillos": "acubillos"
      "Mitchel Roider": "mitchelroider"
      "Johnny Goldsmith": "jgoldsmith"
      
    user_map[hipchat_name]
 
 
  # mobile ---------

  robot.respond /minions status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1158374", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res

  robot.respond /fantastic 4 status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1054874", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res
    
  robot.respond /black dynamite status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1054870", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res

  robot.respond /aqua teen hunger force status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1054864", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res
       
  # web ---------     
      
  robot.respond /dread pirate roberts status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1054880", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res

  robot.respond /#yolo status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1054862", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res
    
  robot.respond /transformers status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1054860", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res

  robot.respond /ocean\'s eleven status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1054856", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res
      
  # IWS ---------
  
  robot.respond /thundercats status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1081884", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res

  robot.respond /infinite monkeys status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1064082", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res
    
  robot.respond /evil geniuses status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1064080", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res
      
  robot.respond /avengers status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1064078", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res
      
  # LA Teams ------
  
  robot.respond /avengers status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1257032", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res
      
  robot.respond /ghostbusters status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1257028", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res
      
  robot.respond /kung fu pandas status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1257034", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res
      
  robot.respond /voltron force status$/i, (res) ->
    res.send "Let me gather that info for you..."
    data = getIterationData "1257036", "current", res, (data) ->
      parseIterationDataAndPostMessage data, res
      
  robot.respond /(.*) issues/i, (res) ->
    res.send "Let me gather that info for you..."
    project = res.match[1]
    getGituhbIssues project, res
    

  robot.respond /my work$/i, (res) ->
    res.send "Let me gather that info for you..."
    
    # pod d
    getIterationData "1158374", "current", res, (data) ->
      getStoryDetails "1158374", data[0].stories, res
      
    # pod c
    getIterationData "1054874", "current", res, (data) ->
      getStoryDetails "1054874", data[0].stories, res
 
    # pod b
    getIterationData "1054870", "current", res, (data) ->
      getStoryDetails "1054870", data[0].stories, res
      
    #pod a
    getIterationData "1054864", "current", res, (data) ->
      getStoryDetails "1054864", data[0].stories, res
      
    username = getGithubUsername res.envelope.user.name
    getGituhbIssues "ios_apartmentguide", res, username
    getGituhbIssues "Bishop", res, username
    getGituhbIssues "ios_maxleases", res, username
    getGituhbIssues "android_maxleases", res, username
      
  robot.respond /ready for (.*)$/i, (res) ->
    res.send "Let me gather that info for you..."
    
    term = res.match[1]

    switch term
      when "qa"
        # pod d
        getIterationData "1158374", "current", res, (data) ->
          getQAStories "1158374", data[0].stories, res
      
        # pod c
        getIterationData "1054874", "current", res, (data) ->
          getQAStories "1054874", data[0].stories, res
      
        # pod b
        getIterationData "1054870", "current", res, (data) ->
          getQAStories "1054870", data[0].stories, res
      
        #pod a
        getIterationData "1054864", "current", res, (data) ->
          getQAStories "1054864", data[0].stories, res
          
      when "product"
        # pod d
        getIterationData "1158374", "current", res, (data) ->
          getProductStories "1158374", data[0].stories, res
      
        # pod c
        getIterationData "1054874", "current", res, (data) ->
          getProductStories "1054874", data[0].stories, res
      
        # pod b
        getIterationData "1054870", "current", res, (data) ->
          getProductStories "1054870", data[0].stories, res
      
        #pod a
        getIterationData "1054864", "current", res, (data) ->
          getProductStories "1054864", data[0].stories, res
          
      when "estimation"
        # pod d
        getUnestimatedStories "1158374", res
      
        # pod c
        getUnestimatedStories "1054874", res
      
        # pod b
        getUnestimatedStories "1054870", res
      
        #pod a
        getUnestimatedStories "1054864", res
      
  robot.hear /not working/i, (res) ->
    res.send "Have you tried turning it off and back on again?"
    
  robot.hear /isn\'t working/i, (res) ->
    res.send "Have you tried turning it off and back on again?"
    

  # robot.hear /badger/i, (res) ->
  #   res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
