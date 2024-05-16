#!/bin/bash

$(tmux kill-session)
$(killall -9 node)
$(killall -9 ruby)

tmux \
  new-session\; \
  split-window -h\; \
  send-keys -t %0 'cd ~/workspace/api_app && rails s -p 10000' C-m\; \
  split-window -v\; \
  send-keys -t %1 'cd ~/workspace/tools_app && rails s -p 10002' C-m\; \
  split-window -v\; \
  send-keys -t %2 'cd ~/workspace/web_app && nvm use && VITE_DEV_PROXY_URL="http://localhost:10000/api/v1" VITE_API_APP_BASE_URL="/api/v1" API_APP_BASE_URL="http://localhost:10000/api/v1" VITE_TOOLS_APP_BASE_URL="http://localhost:10002/tools" npm run dev' C-m\; \
  split-window \; \
  send-keys -t %3 'RACK_TIMEOUT_SERVICE_TIMEOUT=0 ADMIN_SLACK_CHANNEL=allan-notifs-int SMS_AND_PUSH_TO_SLACK=true cd ~/workspace/api_app && bundle exec sidekiq -C ./config/sidekiq.yml' C-m\; \
  split-window -h \; \
  send-keys -t %4 'cd ~/workspace/tools_app && bundle exec sidekiq -C config/sidekiq.yml' C-m\; \
  send-keys -t %5 'sleep 5 && cd ~/workspace/facility_app && npm run dev' C-m\; \
  select-layout tiled \;