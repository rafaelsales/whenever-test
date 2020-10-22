### Whenever::Test

[![Gem Downloads](http://img.shields.io/gem/dt/whenever-test.svg)](https://rubygems.org/gems/whenever-test)
[![Build Status](https://snap-ci.com/heartbits/whenever-test/branch/master/build_image)](https://snap-ci.com/heartbits/whenever-test/branch/master)
[![GitHub Issues](https://img.shields.io/github/issues/rafaelsales/whenever-test.svg)](https://github.com/rafaelsales/whenever-test/issues)
[![GitHub License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/rafaelsales/whenever-test)

A gem that adds test support to [Whenever](https://github.com/javan/whenever) gem.

### Background

I've been part of many projects that used [Whenever](https://github.com/javan/whenever), but testing the `schedule.rb` file was always neglected.

Turns out your jobs defined in [Whenever](https://github.com/javan/whenever) schedule might reference rake tasks that don't exist in runtime and not even have correct ruby syntax (in case of runner-type jobs).

This gem adds a support class so you can write specs that assert against definitions in the `schedule.rb` file. To make sure ruby statements referenced in runner-type jobs actually work, you can `instance_eval` them and write expectations on what should happen, and then you'll be sure cron jobs won't have runtime issues that are detected only in staging or production environments.

NOTE: *This gem is test-framework agnostic, so you can use with RSpec, MiniTest, ...*

### Installation

Since it's available in [Rubygems](https://rubygems.org/gems/whenever-test), just add the following to your Gemfile:

```ruby
group :test do
  gem 'whenever-test'
end
```

### Usage

Suppose you have a schedule such as:

```ruby
# config/schedule.rb
job_type :curl, 'curl :task'

every :hour { runner 'TimeoutOffers.perform_async' }
every :minute { curl 'http://myapp.com/cron-alive' }

if @environment == 'staging'
  every :day { rake 'db_sync:import' }
end
```

You can write a spec such as (RSpec was used in this example):

```ruby
# spec/whenever_spec.rb
require 'spec_helper'

describe 'Whenever Schedule' do
  before do
    load 'Rakefile' # Makes sure rake tasks are loaded so you can assert in rake jobs
  end

  it 'makes sure `runner` statements exist' do
    schedule = Whenever::Test::Schedule.new(file: 'config/schedule.rb')

    assert_equal 2, schedule.jobs[:runner].count

    # Executes the actual ruby statement to make sure all constants and methods exist:
    schedule.jobs[:runner].each { |job| instance_eval job[:task] }
  end

  it 'makes sure `rake` statements exist' do
    # config/schedule.rb file is used by default in constructor:
    schedule = Whenever::Test::Schedule.new(vars: { environment: 'staging' })

    # Makes sure the rake task is defined:
    assert Rake::Task.task_defined?(schedule.jobs[:rake].first[:task])
  end

  it 'makes sure cron alive monitor is registered in minute basis' do
    schedule = Whenever::Test::Schedule.new(file: fixture)

    assert_equal 'http://myapp.com/cron-alive', schedule.jobs[:curl].first[:task]
    assert_equal 'curl :task', schedule.jobs[:curl].first[:command]
    assert_equal [:minute], schedule.jobs[:curl].first[:every]
  end
end
```

**Now the important part:** these specs guarantee that:

1. If `TimeoutOffers` constant is not defined or `TimeoutOffers.perform_async` method doesn't exist, the spec fails
2. If Rake task `db_sync:import` doesn't exist, the spec fails
3. You should have a custom task named `curl` to make sure that job will work, otherwise the spec fails

### How it works

This gem implements a class that has the same DSL interface as Whenever gem. It basically runs the `schedule.rb` file against `Whenever::Test::DSLInterpreter` and stores all statements and parameters found so you can easily query them in your tests.

### Contributors

* Rafael Sales [@rafaelsales](https://github.com/rafaelsales)
* Mike Stewart [@mike-stewart](https://github.com/mike-stewart)

### Contributing

1. Fork it ( https://github.com/rafaelsales/whenever-test/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
