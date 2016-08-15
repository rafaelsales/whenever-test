module Whenever::Test
  class DSLInterpreter
    def initialize(schedule_world)
      @_world = schedule_world
    end

    def job_type(job, command)
      @_world.jobs[job] = []
      define_singleton_method(job) do |task, *_args|
        @_world.jobs[job] << StrictHash[task: task, every: @_current_every, command: command]
      end
    end

    def every(*args, &block)
      @_current_every = args
      yield
    end

    def set(name, value)
      instance_variable_set("@#{name}".to_sym, value)
      self.class.send(:attr_reader, name.to_sym)

      @_world.sets[name] = value
    end

    def env(name, value)
      @_world.envs[name] = value
    end
  end
end
