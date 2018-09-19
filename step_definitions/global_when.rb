#common utilities

#==============================================================================================================#
#********************************************** AUTO LOGIN ****************************************************#
#==============================================================================================================#
When /^I navigate to add event page$/ do
  @driver.find_element(:accessibility_id => "Add Event").click
  sleep 2
end

When /^I create a "([^"]*)" event$/ do|eventtype|

  @driver.find_element(:accessibility_id => "editEventNameField").send_keys("Test")
  @driver.find_element(:accessibility_id => "editEventTypeField").send_keys(eventtype)
  @driver.find_element(:xpath => "//XCUIElementTypeDatePicker[@name='editEventDateField']//XCUIElementTypePickerWheel[1]").send_keys("Today")
  @driver.find_element(:xpath => "//XCUIElementTypeDatePicker[@name='editEventDateField']//XCUIElementTypePickerWheel[2]").send_keys("4 o'clock")
  @driver.find_element(:xpath => "//XCUIElementTypeDatePicker[@name='editEventDateField']//XCUIElementTypePickerWheel[3]").send_keys("23 minutes")
  @driver.find_element(:xpath => "//XCUIElementTypeDatePicker[@name='editEventDateField']//XCUIElementTypePickerWheel[4]").send_keys("AM")
  @driver.find_element(:accessibility_id => "Save").click
  sleep 3
end

When /^I update an "([^"]*)" event$/ do|eventtype|
  sleep 2
  @driver.find_element(:xpath => "//XCUIElementTypeCell[@name='#{eventtype}']").click
  @driver.find_element(:accessibility_id => "editEventNameField").clear
  @driver.find_element(:accessibility_id => "editEventNameField").send_keys("Updated Event")
  @driver.find_element(:accessibility_id => "Save").click
  sleep 3
end

When /^I update an "([^"]*)" event with empty$/ do|eventtype|
  sleep 2
  @driver.find_element(:xpath => "//XCUIElementTypeCell[@name='#{eventtype}']").click
  @driver.find_element(:accessibility_id => "editEventNameField").clear
  @driver.find_element(:accessibility_id => "Save").click
  sleep 3
end