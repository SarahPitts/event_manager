require 'csv'
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_homephone(homephone) 
homephone = homephone.gsub(/[^0-9]/, '')
  if homephone.nil?
    "0000000000"
  elsif homephone.length < 10
    homephone.rjust(10,"0")
  elsif homephone.length > 10
    homephone[0..9]
  else
    homephone
  end
end


def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  homephone = clean_homephone(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])
  reghour = DateTime.strptime(row[:regdate],'%m/%d/%y %H:%M').hour
  regday = DateTime.strptime(row[:regdate],'%m/%d/%y %H:%M').day
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letters(id,form_letter)
end
