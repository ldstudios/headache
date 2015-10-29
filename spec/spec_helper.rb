require 'bundler/setup'

Bundler.setup

require 'factory_girl'
require 'simplecov'
require 'coveralls'

::SimpleCov.add_filter 'spec'
Coveralls.wear!

require 'headache'

Dir['./spec/support/**/*.rb'].each { |f| require f }
Dir['./spec/factories/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
end
