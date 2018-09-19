require 'selenium-webdriver'
require 'appium_lib'
#
Then /^I should see event date in yyyy-mm-dd hh:mm$/ do
  noevent = @driver.find_elements(:xpath => "//XCUIElementTypeTable[@name='tableView]//XCUIElementTypeCell").size
  puts noevent
  date_locator = "eventCell-$$-Date"
  cellcount = 0
  while noevent < cellcount
    loc = date_locator.gsub("$$", cellcount.to_s)
    sleep 2
    puts loc
    dat = (@driver.find_element(:accessibility_id => loc).text).strip
    puts dat
    dattime = dat.split(" ")
    put dattime[0]
    puts dattime[1]
    format_ok = dat.match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}/)
    if format_ok
      puts "Date and time format is matched"
    else
      break
    end
    cellcount =cellcount+1
  end
end

Then /^I should see the "([^"]*)" event in event list page$/ do |eventtype|
  noevent = @driver.find_elements(:xpath => "//XCUIElementTypeTable[@name='tableView]//XCUIElementTypeCell").size
  cellcount = 0

  while noevent >= cellcount
    updated = @driver.find_element(:accessibility_id => "eventCell-#{cellcount}-Name").text

    if eventtype.equal? "Updated"
      if updated.eql? "Updated Event"
        break
      end
    elsif eventtype.equal? "Updated"

      if updated.eql? "Meal"
        break
      end
    end

  end
end


Then /^I should not see the "([^"]*)" event in event list page$/ do |eventtype|
  noevent = @driver.find_elements(:xpath => "//XCUIElementTypeTable[@name='tableView]//XCUIElementTypeCell").size
  cellcount = 0

  while noevent >= cellcount
    updated = @driver.find_element(:accessibility_id => "eventCell-#{cellcount}-Name").text

    if eventtype.equal? "empty"
      if updated.eql? " "
        break
      end
    end
  end
end