set :output, '/var/log/whenever.log'
set :runner_command, 'bundle exec rails runner'
job_type :ping, 'ping :task'
env :PATH, ENV['PATH']

every :day do
  runner 'UpdateAnalyticsMetricsWorker.perform_async'
end

every :hour do
  runner 'TimeoutCampaings.perform_async'
end

every :minute do
  ping 'http://myapp.com/cron-alive'
end

if @environment == 'staging'
  every :day do
    rake 'db_sync:import'
  end
end
