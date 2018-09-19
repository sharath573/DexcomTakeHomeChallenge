require 'os'
require 'selenium-webdriver'
require 'base64'
require_relative 'util'

@step_count = nil # step counter used in AfterStep to get current step name
$scenario_count = 0 # holds scenario count for each feature file
$stepstatus = 'fail'
##==============================================================================================================#
#****************************************** START APPIUM SERVER ************************************************#
##==============================================================================================================#
# port
free_port = rand(65000 - 1024) + 1024
retries ||= 0
until Selenium::WebDriver::PortProber.free?(free_port) or ((retries += 1) <= 5)
  free_port = rand(65000 - 1024) + 1024
end
$port = free_port

# bootstrap port
free_port = rand(65000 - 1024) + 1024
retries ||= 0
until Selenium::WebDriver::PortProber.free?(free_port) or ((retries += 1) <= 5)
  free_port = rand(65000 - 1024) + 1024
end
$bport = free_port

appium_command = "appium -a #{HOST} -p #{$port} -cp #{$port} -bp #{$bport}"

Util.log_steps("<APPIUM_SERVER_INFO>: #{appium_command}", 'TEST_CASE_INFO')
begin
  if OS.mac?
    system("osascript -e 'tell application \"Terminal\" to activate' -e 'tell application \"Terminal\" to do script \"#{appium_command}\"'")
  else
    system("start cmd.exe @cmd /k \"#{appium_command}\"")
  end

  max_wait_time = 60

  until !(Selenium::WebDriver::PortProber.free?($port)) or max_wait_time == 0
    sleep 1
    max_wait_time -= 1
  end
rescue => e
  Util.log_steps("Exception while starting Appium server => #{e}")
end
Util.log_steps("Successfully started Appium server => '#{appium_command}'")
@arr_steps = []
##==============================================================================================================#
#****************************************** CUCUMBER - BEFORE DO ***********************************************#
##==============================================================================================================#
# Description: Things to be completed before starting the script execution.
Before do


  app_name = "#{File.dirname(__FILE__)}/..#{($config['appium']['ios']['app']).gsub('$app_name$', $product)}"
  Util.log_steps("#{$product} app not found in native_application folder for testing in #{$platform}", 'FAIL', false) unless File.exists?(app_name)
  # getting desired capabilities for iOS platform
  caps = {
      deviceName: "iPhone X",
      platformName: 'iOS',
      platformVersion: $platform_version,
      app: app_name,
      noReset: true,
      automationName: 'XCUITest',
      newCommandTimeout: $config['appium']['new_command_timeout'],
      udid: "1ACC35B8-1C0C-4572-B973-3DB40D92C6FE",
      sendKeyStrategy: 'setValue',
      autoAcceptAlerts: true,
      acceptAllAlerts: true
  }
  desired_caps = {
      caps: caps,
      appium_lib: {
          server_url: "http://#{HOST}:#{$port}/wd/hub"
      }
  }
  driver_instance =
      begin
        driver_instance = Appium::Driver.new(desired_caps)
        driver_instance.start_driver
      rescue => e
        Util.log_steps("Failed to start driver: #{e}", 'FAIL', false)
      end

  @driver = driver_instance
end

AfterStep do

end

After do

  @driver.quit

end

##==============================================================================================================#
#************************************** CUCUMBER - AFTER CONFIGURATION *****************************************#
##==============================================================================================================#
# Description       : called after support has been loaded but before features are loaded
# Arguments         :
#   config          : config object
#
AfterConfiguration do |config|

end

##==============================================================================================================#
#**************************************** AT THE END OF EXECUTION **********************************************#
##==============================================================================================================#
# steps to execute at the end of execution
at_exit do

  begin
    Util.log_steps("Killing Appium server..", 'DEBUG')
    if Selenium::WebDriver::PortProber.free?($port)
    else
      if OS.mac?
        process_id = (`lsof -n -i4TCP:#{$port} | grep LISTEN`).gsub(/\s+/, ' ').split(' ')[1]
        `kill #{process_id}`
      else
        process_id = (`netstat -ano | findstr #{$port}`).gsub(/\s+/, ' ').split(' ')[4]
        `taskkill /F /PID #{process_id}`
      end

      max_attempt = 30
      until Selenium::WebDriver::PortProber.free?($port) or (max_attempt == 0)
        sleep 30
        max_attempt -= 1
      end
    end
    Util.log_steps("Successfully killed Appium server..")
  rescue
    puts 'Failed while killing Appium server... (at_exit)'
  end
end
