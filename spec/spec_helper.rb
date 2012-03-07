# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'thinking_sphinx/test'
require 'open-uri'

#Dir[Rails.root.join("test/factories/*")].each {|f| require f}
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

#FakeWeb.allow_net_connect = false

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
#  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.color_enabled = true
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.include Factory::Syntax::Methods
    
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    #ThinkingSphinx::Test.init
    #ThinkingSphinx::Test.start_with_autostop
  end
  
  # reset the factories sequences
  config.before(:each) do
    FactoryGirl.reload
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# queria que isso fosse mais rapido
def login
#  post login_path, :password => APP_CONFIG['password']
  visit login_path
      
  fill_in "password", :with => APP_CONFIG['password']
  click_button "Entrar"
end


# these lines are usefull for testing delete with js.
def js_confirm(status)
  page.evaluate_script 'window.original_confirm_function = window.confirm;'
  page.evaluate_script "window.confirm = function(msg) { return #{status == 'accept'}; }"
  yield
  page.evaluate_script 'window.confirm = window.original_confirm_function;'
end

def accept_js_confirm
  js_confirm('accept'){ yield }
end

def reject_js_confirm
  js_confirm('reject'){ yield }
end
