module Whenever::Test
  class StrictHash < Hash
    alias [] fetch
  end
end
