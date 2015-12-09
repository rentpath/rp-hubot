#!/bin/bash

source ~/.bash_profile
export HUBOT_APPANNIE_TOKEN=17990a6ba1bd237cfe42ef35145a437b1d05edf4
#export HUBOT_HIPCHAT_JID=119167_1155238@chat.hipchat.com
#export HUBOT_HIPCHAT_PASSWORD=owXtvpDaAH9AV8gNzRzN
#export HUBOT_HIPCHAT_ROOMS=119167_bot_test@conf.hipchat.com,119167_mobile@conf.hipchat.com,119167_mobile_pod_a@conf.hipchat.com,119167_mobile_pod_b@conf.hipchat.com,119167_mobile_pod_c@conf.hipchat.com,119167_mobile_pod_d@conf.hipchat.com,119167_mobile_qa@conf.hipchat.com,119167_web@conf.hipchat.com,119167_web_pod_a@conf.hipchat.com,119167_web_pod_b@conf.hipchat.com,119167_web_pod_c@conf.hipchat.com,119167_web_pod_d@conf.hipchat.com,119167_web_pod_e@conf.hipchat.com,119167_iws_pod_f@conf.hipchat.com,119167_engineering@conf.hipchat.com
export PATH=${PATH}:/usr/local/:/usr/local/hubot:/usr/local/hubot/node_modules:/usr/local/hubot/bin:/Users/engineer/.nvm/versions/node/v0.12.2/bin

cd /usr/local/hubot
bin/hubot --adapter slack
