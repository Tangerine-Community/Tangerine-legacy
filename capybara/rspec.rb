require 'rubygems'
require 'selenium-webdriver'
require 'capybara'
require 'capybara/rspec'
require './config.rb'
require './helpers/helpers.rb'


Capybara.register_driver :selenium do |app|
 #caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => [ "--verbose --log-path=chromedriver.log" ]})
 #Capybara::Selenium::Driver.new(app, :browser => :chrome, :desired_capabilities => caps)
 Capybara::Selenium::Driver.new(app)
 
end

Capybara.configure do |config|
  config.run_server     = false
  config.default_driver = :selenium
  config.app_host       = 'http://databases.tangerinecentral.org/tangerine/_design/ojai/index.html'
end


#require './features/sign_in.rb'
#require './features/groups.rb'
#require './features/assessment_screen.rb'
#require './features/basic_assessment.rb'

#require './features/grids.rb'
#require './features/surveys.rb'
require './features/upload.rb'
