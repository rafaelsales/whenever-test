require 'spec_helper'

describe Whenever::Test::Schedule do
  let(:fixture) { 'spec/fixtures/schedule.rb' }
  before { load 'spec/fixtures/db_sync.rake' }

  describe '#jobs' do
    it 'makes sure `runner` statements are captured' do
      schedule = Whenever::Test::Schedule.new(file: fixture)

      assert_equal 2, schedule.jobs[:runner].count

      # Executes the actual ruby statement to make sure the constant and method exists:
      schedule.jobs[:runner].each { |job| instance_eval job[:task] }
    end

    it 'makes sure `rake` statements are captured' do
      schedule = Whenever::Test::Schedule.new(file: fixture, vars: { environment: 'staging' })

      # Makes sure the rake task is defined:
      assert Rake::Task.task_defined?(schedule.jobs[:rake].first[:task])
    end

    it 'makes sure custom job_type tasks are registered' do
      schedule = Whenever::Test::Schedule.new(file: fixture)

      assert_equal 'http://myapp.com/cron-alive', schedule.jobs[:ping].first[:task]
      assert_equal 'ping :task', schedule.jobs[:ping].first[:command]
      assert_equal [:minute], schedule.jobs[:ping].first[:every]
    end
  end

  it 'makes sure `set` statements are captured ' do
    schedule = Whenever::Test::Schedule.new(file: fixture)

    assert_equal 'bundle exec rails runner', schedule.sets[:runner_command]
  end

  it 'makes sure `env` statements are captured ' do
    schedule = Whenever::Test::Schedule.new(file: fixture)

    assert_equal ENV['PATH'], schedule.envs[:PATH]
  end

  class TimeoutCampaings
    def self.perform_async; end
  end

  class UpdateAnalyticsMetricsWorker
    def self.perform_async; end
  end
end
