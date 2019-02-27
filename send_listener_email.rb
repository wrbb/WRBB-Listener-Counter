#!/usr/bin/env ruby
require 'mail'
require 'csv'

TO_EMAIL = 'mail@brycethuilot.com'.freeze # 'andrew@wrbbradio.org'
FROM_EMAIL = 'listener@wrbbradio.org'.freeze
FILE_LOCATION = ENV['HOME'] + '/.listeners.csv'
DATE_FORMAT = '%-m/%-d'.freeze
USER_NAME = FROM_EMAIL
PASSWORD = 'oushimiteeverconfu'.freeze
PAST_DATE_DIFFERENCE_SECONDS = (7 * 24 * 60 * 60)

def average_listeners(csv_data)
  total = 0
  count = 0
  csv_data.each do |data|
    total += data[3].to_i
    count += 1
  end

  return total / count unless count.zero?
end

def most_listened_to(csv_data)
  csv_data.sort_by! { |data| data[3].to_i }
  return csv_data[-1]
end

def get_body_text(csv_data)
  csv_data.delete_at(0)
  top_show = most_listened_to csv_data
  body = "Statistics for listeners: \n"\
  "Average listners: #{average_listeners csv_data}\n"\
  "Highest listeners: #{top_show[3]}\n"\
  "During show: #{top_show[2]} On: #{top_show[0]} at #{top_show[1]}"
end

def set_mail_defaults
  settings = { address: 'smtp.gmail.com', port: 587,
               user_name: USER_NAME,
               password: PASSWORD,
               authentication: :plain,
               enable_starttls_auto: true }
  Mail.defaults do
    delivery_method :smtp, settings
  end
end

def send_email(body_text, past_date_string, today_string)
  set_mail_defaults
  Mail.deliver do
    from FROM_EMAIL
    to       TO_EMAIL
    subject  "Listener statistics (#{past_date_string} to #{today_string})"
    body body_text
    add_file filename: "#{past_date_string}-#{today_string}-Listeners.csv",
             content: File.read(FILE_LOCATION)
  end
end

# Main method to run
def main
  # Get Todays date
  today = Time.now
  # Subtract how many seconds to in past data is from from todays epoch time
  #   Then construct new object
  seven_days_ago = Time.at(today.to_i - PAST_DATE_DIFFERENCE_SECONDS)
  # Call method to get the body text based on stats for this time peroid
  body = get_body_text CSV.read(FILE_LOCATION)
  send_email body, seven_days_ago.strftime(DATE_FORMAT),
             today.strftime(DATE_FORMAT)

  ARGV.each do |arg|
    File.delete(FILE_LOCATION) if arg == 'delete'
  end
end

main
