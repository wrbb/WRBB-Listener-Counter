#!/usr/bin/env ruby
require 'selenium-webdriver'

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument "--headless"
$driver = Selenium::WebDriver.for :chrome, options: options

# Has the driver go to a url
def goto url
    $driver.navigate.to url
end

# Gets the current show name
def get_show_name 
    goto 'https://spinitron.com/WRBB/'
    # Find the element with Current show name
    return $driver.find_element(class: 'current-show').find_element(tag_name: 'a').text
end

# Gets the current listener count
def get_listener_count
    # Go to icecast
    goto 'http://129.10.161.130:8000/status.xsl'
    # Get all of rows with data
    rows = $driver.find_elements(tag_name: 'tr')
    rows.each do |row|
        # For each, get the cells
        cells = row.find_elements(tag_name: 'td')
        # If teh first cell's text is Current Listeners, Return the second
        if cells[0].text == "Current Listeners:"
            return cells[1].text
        end
    end
    # return N/A if could not be found
    return "N/A"

end

puts "Current show: " + get_show_name
puts "Listener: " + get_listener_count

