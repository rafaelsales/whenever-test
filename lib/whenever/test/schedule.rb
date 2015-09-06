module Whenever::Test
  class Schedule
    attr_accessor :jobs, :envs, :sets

    def initialize(file: 'config/schedule.rb', vars: {})
      self.jobs = {}
      self.envs = {}
      self.sets = {}

      dsl = DSLInterpreter.new(self, vars)
      setup_whenever(dsl)
      parse(dsl, file)
    end

    private

    def setup_whenever(dsl)
      parse(dsl, File.join(Gem.loaded_specs['whenever'].full_gem_path, 'lib', 'whenever', 'setup.rb').to_s)
    end

    def parse(dsl, file)
      dsl.instance_eval File.read(file)
    end
  end
end
