RSpec.configure do |config|
  config.before(:each) { Redis.current.flushdb }
end
