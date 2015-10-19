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

  app_annie_key = process.env.HUBOT_APPANNIE_TOKEN
  
  getAnalyticsData = (account_id, product_id, start_date, end_date, res, callback) ->
    url = "https://api.appannie.com/v1.2/accounts/#{account_id}/products/#{product_id}/sales?break_down=date&start_date=#{start_date}&end_date=#{end_date}"
    request = robot.http(url)
    request.header('Accept', 'application/json')
    request.header('Authorization', "bearer #{app_annie_key}")
    request.get() (err, response, body) ->
      
      if err
        res.send "Encountered an error :( #{err}"
        return
      
      if typeof response is 'undefined'
        res.send "Response was undefied :("
        return
        
      if response.statusCode isnt 200
        res.send response.headers
        res.send "Request didn't come back HTTP 200 :( - #{response.statusCode}"
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
      catch error
        res.send "Ran into an error parsing analytics JSON :( - #{error}"
        return
        
      callback data
      
  getRankData = (market, product_id, date, res, callback) ->
    url = "https://api.appannie.com/v1.2/apps/#{market}/app/#{product_id}/ranks?start_date=#{date}&end_date=#{date}&countries=US"
    request = robot.http(url)
    request.header('Accept', 'application/json')
    request.header('Authorization', "bearer #{app_annie_key}")
    request.get() (err, response, body) ->
      
      if err
        res.send "Encountered an error :( #{err}"
        return
      
      if typeof response is 'undefined'
        res.send "Response was undefied :("
        return
        
      if response.statusCode isnt 200
        res.send "Request didn't come back HTTP 200 :( - #{response.statusCode}"
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
      catch error
        res.send "Ran into an error parsing analytics JSON :( - #{error}"
        return
        
      callback data
        
  formattedDate = (date, res) ->
    day = null
    month = null
    try
      month = date.getMonth() + 1 # + 1 due to getMonth() returning index based integer and not actual month number
      month = "0#{month}" if month < 10
      day = date.getDate()
      day = "0#{day}" if day < 10
    catch error
      res.send "Error creating date strings - #{error}"
      return
    "#{date.getFullYear()}-#{month}-#{day}"
    
  fetchAnalyticsForAndroidProducts = (start_date, end_date, res, completion) ->
    message = ""
      
    # Lovely Android
    getAnalyticsData "250867", "20600001791355", start_date, end_date, res, (data1) ->
      product = null
      message += "Lovely Android:\n"
      downloads = 0
      updates = 0
      for sale in data1.sales_list
        product = sale.units.product
        downloads += product.downloads if !!product and !!product.downloads
        updates += product.updates if !!product and !!product.updates
  
      downloads = "Who Knows?!" if downloads is 0
      updates = "Who Knows?!" if updates is 0
  
      message += ">> Downloads: #{downloads}\n" +
      ">> Updates: #{updates}\n"
    
      # AG Android
      getAnalyticsData "231848", "20600000069646", start_date, end_date, res, (data3) ->
        product = null
        message += "AG Android:\n"
        downloads = 0
        updates = 0
        for sale in data3.sales_list
          product = sale.units.product
          downloads += product.downloads if !!product and !!product.downloads
          updates += product.updates if !!product and !!product.updates
    
        downloads = "Who Knows?!" if downloads is 0
        updates = "Who Knows?!" if updates is 0
        
        message += ">> Downloads: #{downloads}\n" +
        ">> Updates: #{updates}\n"
  
        # Rent Android
        getAnalyticsData "231848", "20600000080478", start_date, end_date, res, (data5) ->
          product = null
          message += "Rent Android:\n"
          downloads = 0
          updates = 0
          for sale in data5.sales_list
            product = sale.units.product
            downloads += product.downloads if !!product and !!product.downloads
            updates += product.updates if !!product and !!product.updates
      
          downloads = "Who Knows?!" if downloads is 0
          updates = "Who Knows?!" if updates is 0
          
          message += ">> Downloads: #{downloads}\n" +
          ">> Updates: #{updates}\n"

          # Rentals Android
          getAnalyticsData "231848", "20600000130169", start_date, end_date, res, (data7) ->
            product = null
            message += "Rentals Android:\n"
            downloads = 0
            updates = 0
            for sale in data7.sales_list
              product = sale.units.product
              downloads += product.downloads if !!product and !!product.downloads
              updates += product.updates if !!product and !!product.updates
        
            downloads = "Who Knows?!" if downloads is 0
            updates = "Who Knows?!" if updates is 0
            
            message += ">> Downloads: #{downloads}\n" +
            ">> Updates: #{updates}\n"

            completion message
                    
  fetchAnalyticsForiOSProducts = (start_date, end_date, res, completion) ->
    message = ""
    
    # Lovely iOS
    getAnalyticsData "265984", "576063727", start_date, end_date, res, (data) ->
      message += "Lovely iOS:\n"
      downloads = 0
      updates = 0
      for sale in data.sales_list
        product = sale.units.product
        downloads += product.downloads if !!product and !!product.downloads
        updates += product.updates if !!product and !!product.updates
        
      downloads = "Who Knows?!" if downloads is 0
      updates = "Who Knows?!" if updates is 0
        
      message += ">> Downloads: #{downloads}\n" +
      ">> Updates: #{updates}\n"
    
      # AG iOS
      getAnalyticsData "231841", "292234839", start_date, end_date, res, (data2) ->
        product = null
        message += "AG iOS:\n"
        downloads = 0
        updates = 0
        for sale in data2.sales_list
          product = sale.units.product
          downloads += product.downloads if !!product and !!product.downloads
          updates += product.updates if !!product and !!product.updates
    
        downloads = "Who Knows?!" if downloads is 0
        updates = "Who Knows?!" if updates is 0
        
        message += ">> Downloads: #{downloads}\n" +
        ">> Updates: #{updates}\n"
    
        # Rent iOS
        getAnalyticsData "231841", "388038507", start_date, end_date, res, (data4) ->
          product = null
          message += "Rent iOS:\n"
          downloads = 0
          updates = 0
          for sale in data4.sales_list
            product = sale.units.product
            downloads += product.downloads if !!product and !!product.downloads
            updates += product.updates if !!product and !!product.updates
    
          downloads = "Who Knows?!" if downloads is 0
          updates = "Who Knows?!" if updates is 0
          
          message += ">> Downloads: #{downloads}\n" +
          ">> Updates: #{updates}\n"
    
          # Rentals iOS
          getAnalyticsData "231841", "356893297", start_date, end_date, res, (data6) ->
            product = null
            message += "Rentals iOS:\n"
            downloads = 0
            updates = 0
            for sale in data6.sales_list
              product = sale.units.product
              downloads += product.downloads if !!product and !!product.downloads
              updates += product.updates if !!product and !!product.updates
    
            downloads = "Who Knows?!" if downloads is 0
            updates = "Who Knows?!" if updates is 0
            
            message += ">> Downloads: #{downloads}\n" +
            ">> Updates: #{updates}\n"
            
            completion message
            
  fetchAnalyticsForAllProducts = (start_date, end_date, res, completion) ->
    message = ""
    fetchAnalyticsForiOSProducts start_date, end_date, res, (message1) ->
      message += message1
      fetchAnalyticsForAndroidProducts start_date, end_date, res, (message2) ->
        message += message2
        completion message
  
  robot.respond /metrics$/i, (res) ->
    res.send "Gathering metrics data, please wait..."
    
    start_date = ""
    end_date = ""
    try
      d = new Date()
      end_date = formattedDate(d, res)
      d.setDate(d.getDate() - 1)
      start_date = formattedDate(d, res)
    catch error
      res.send "Ran into an error creating Date obejcts :( - #{error}"
      return
      
    fetchAnalyticsForAllProducts start_date, start_date, res, (message) ->
      res.send "Here are the metrics for yesterday (#{start_date}) for all apps:\n" + message
  
  robot.respond /metrics (.*)$/i, (res) ->
    res.send "Gathering metrics data, please wait..."
    term = res.match[1]
    switch term
      when "ios"
        start_date = ""
        end_date = ""
        try
          d = new Date()
          end_date = formattedDate(d, res)
          d.setDate(d.getDate() - 1)
          start_date = formattedDate(d, res)
        catch error
          res.send "Ran into an error creating Date obejcts :( - #{error}"
          return
        fetchAnalyticsForiOSProducts start_date, start_date, res, (message) ->
          res.send "Here are the metrics for yesterday (#{start_date}) for iOS:\n" + message
          
      when "android"
        start_date = ""
        end_date = ""
        try
          d = new Date()
          end_date = formattedDate(d, res)
          d.setDate(d.getDate() - 1)
          start_date = formattedDate(d, res)
        catch error
          res.send "Ran into an error creating Date obejcts :( - #{error}"
          return
        fetchAnalyticsForAndroidProducts start_date, start_date, res, (message) ->
          res.send "Here are the metrics for yesterday (#{start_date}) for Google Play:\n" + message
          
      when "wtd"
        date = new Date()
        first = date.getDate() - date.getDay()
        last = first + 6
        start_date = new Date(date.setDate(first))
        end_date = new Date(date.setDate(date.getDate() + 6))
        formatted_start_date = formattedDate start_date, res
        formatted_end_date = formattedDate end_date, res
        fetchAnalyticsForAllProducts formatted_start_date, formatted_end_date, res, (message) ->
          res.send "Here are the WTD metrics for all apps:\n" + message
          
      when "wtd ios", "ios wtd"
        date = new Date()
        first = date.getDate() - date.getDay()
        last = first + 6
        start_date = new Date(date.setDate(first))
        end_date = new Date(date.setDate(date.getDate() + 6))
        formatted_start_date = formattedDate start_date, res
        formatted_end_date = formattedDate end_date, res
        fetchAnalyticsForiOSProducts formatted_start_date, formatted_end_date, res, (message) ->
          res.send "Here are the WTD metrics for iOS:\n" + message
            
      when "wtd android", "android wtd"
        date = new Date()
        first = date.getDate() - date.getDay()
        last = first + 6
        start_date = new Date(date.setDate(first))
        end_date = new Date(date.setDate(date.getDate() + 6))
        formatted_start_date = formattedDate start_date, res
        formatted_end_date = formattedDate end_date, res
        fetchAnalyticsForAndroidProducts formatted_start_date, formatted_end_date, res, (message) ->
          res.send "Here are the WTD metrics for Google Play:\n" + message
            
      when "mtd"
        end_date = new Date()
        y = end_date.getFullYear()
        m = end_date.getMonth()
        start_date = new Date(y, m, 1)
        formatted_start_date = formattedDate start_date, res
        formatted_end_date = formattedDate end_date, res
        fetchAnalyticsForAllProducts formatted_start_date, formatted_end_date, res, (message) ->
          res.send "Here are the MTD metrics for all apps:\n" + message
          
      when "mtd ios", "ios mtd"
        end_date = new Date()
        y = end_date.getFullYear()
        m = end_date.getMonth()
        start_date = new Date(y, m, 1)
        formatted_start_date = formattedDate start_date, res
        formatted_end_date = formattedDate end_date, res
        fetchAnalyticsForiOSProducts formatted_start_date, formatted_end_date, res, (message) ->
          res.send "Here are the WTD metrics for iOS:\n" + message
          
      when "mtd android", "android mtd"
        end_date = new Date()
        y = end_date.getFullYear()
        m = end_date.getMonth()
        start_date = new Date(y, m, 1)
        formatted_start_date = formattedDate start_date, res
        formatted_end_date = formattedDate end_date, res
        fetchAnalyticsForAndroidProducts formatted_start_date, formatted_end_date, res, (message) ->
          res.send "Here are the MTD metrics for Google Play:\n" + message
        
  robot.respond /ranks$/i, (res) ->
    res.send "Gathering rank data, please wait..."
    message = ""
    d = new Date()
    d.setDate(d.getDate() - 1)
    
    # Lovely iOS
    getRankData "ios", "576063727", formattedDate(d, res), res, (data1) ->
      try
        if data1.product_ranks.length > 0
          for rank in data1.product_ranks
            for key, value of rank.ranks
              message += "Lovely iOS Rank: ##{value} (#{rank['category']})\n"
              break
        else
          message += "Lovely iOS Rank: Who Knows?!\n"
      catch error
        res.send "Error: #{error}"
      
      # Lovley Android
      getRankData "google-play", "20600001791355", formattedDate(d, res), res, (data2) ->
        try
          if data2.product_ranks.length > 0
            for rank in data2.product_ranks
              for key, value of rank.ranks
                message += "Lovely Android Rank: ##{value} (#{rank['category']})\n"
                break
          else
            message += "Lovely Android Rank: Who Knows?!\n"
        catch error
          res.send "Error: #{error}"
        
        # AG iOS
        getRankData "ios", "292234839", formattedDate(d, res), res, (data3) ->
          try
            if data3.product_ranks.length > 0
              for rank in data3.product_ranks
                for key, value of rank.ranks
                  message += "AG iOS Rank: ##{value} (#{rank['category']})\n"
                  break
            else
              message += "AG iOS Rank: Who Knows?!\n"
          catch error
            res.send "Error: #{error}"
        
          # AG Android
          getRankData "google-play", "20600000069646", formattedDate(d, res), res, (data4) ->              
            try
              if data4.product_ranks.length > 0
                for rank in data4.product_ranks
                  for key, value of rank.ranks
                    message += "AG Android Rank: ##{value} (#{rank['category']})\n"
                    break
              else
                message += "AG Android Rank: Who Knows?!\n"
            catch error
              res.send "Error: #{error}"
        
            # Rent iOS
            getRankData "ios", "388038507", formattedDate(d, res), res, (data5) ->                
              try
                if data5.product_ranks.length > 0
                  for rank in data5.product_ranks
                    for key, value of rank.ranks
                      message += "Rent iOS Rank: ##{value} (#{rank['category']})\n"
                      break
                else
                  message += "Rent iOS Rank: Who Knows?!\n"
              catch error
                res.send "Error: #{error}"
        
              # Rent Android
              getRankData "google-play", "20600000080478", formattedDate(d, res), res, (data6) ->
                try
                  if data6.product_ranks.length > 0
                    for rank in data6.product_ranks
                      for key, value of rank.ranks
                        message += "Rent Android Rank: ##{value} (#{rank['category']})\n"
                        break
                  else
                    message += "Rent Android Rank: Who Knows?!\n"
                catch error
                  res.send "Error: #{error}"
        
                # Rentals iOS
                getRankData "ios", "356893297", formattedDate(d, res), res, (data7) ->
                  try
                    if data7.product_ranks.length > 0
                      for rank in data7.product_ranks
                        for key, value of rank.ranks
                          message += "Rentals iOS Rank: ##{value} (#{rank['category']})\n"
                          break
                    else
                      message += "Rentals iOS Rank: Who Knows?!\n"
                  catch error
                    res.send "Error: #{error}"
        
                  # Rentals Android
                  getRankData "google-play", "20600000130169", formattedDate(d, res), res, (data8) -> 
                    try
                      if data8.product_ranks.length > 0
                        for rank in data8.product_ranks
                          for key, value of rank.ranks
                            message += "Rentals Android Rank: ##{value} (#{rank['category']})\n"
                            break
                      else
                        message += "Rentals Android Rank: Who Knows?!\n"
                    catch error
                      res.send "Error: #{error}"
        
                    res.send message
      
      
        
        