# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "log/whenever.log"

every 2.minutes do
 runner "Widget.record_all_samples!"
end

# Learn more: http://github.com/javan/whenever
