#!/usr/bin/env ruby
require 'csv'
require 'Pathname'
require 'time'
require 'open-uri'
require 'json'
require 'nokogiri'

FILE_NAME = ENV['HOME'] + '/.listeners.csv'
TIME_FORMATING = '%R'.freeze
DATE_FORMATING = '%D'.freeze

def show_name
  api_token = 'ARdWnef9Fie7lKWspQzn5efv'
  base_url = "http://spinitron.com/api/shows?access-token=#{api_token}&count=1"

  response = open(base_url).read
  json_response = JSON.parse(response)
  json_response['items'][0]['title']
end

def listener_count
  page = Nokogiri::HTML(open('http://129.10.161.130:8000/status.xsl'))
  page.css('tr')[7].css('td')[1].text
end

file_exits = Pathname(FILE_NAME).exist?

listener_file = CSV.open(FILE_NAME, 'ab')

listener_file << %w[Date Time Listeners Show] unless file_exits

t = Time.now
current_date = t.strftime(DATE_FORMATING)
current_time = t.strftime(TIME_FORMATING)

listener_file << [current_date, current_time, show_name, listener_count]
