require 'whenever'

Dir.glob(File.join(File.dirname(__FILE__), '/test/**/*.rb')).sort.each { |f| require f }
