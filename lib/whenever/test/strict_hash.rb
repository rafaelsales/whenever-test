module Whenever::Test
  class StrictHash < Hash
    alias_method :[], :fetch
  end
end
