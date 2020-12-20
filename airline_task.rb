require_relative 'lib/airline_seating.rb'
require_relative 'lib/airline_display.rb'
require 'yaml'


config = YAML.load(File.read("config.yml"))
lines = File.readlines(config['Files']['input'])

seating = AirlineSeating.new(lines)
if seating.booking_overflow == true
  puts "Passenger count exceeded total seats!!"
end

puts "total number of seats = #{seating.total_seats}"
puts "passengers count = #{seating.passengers_count}"

result = seating.arrangement
outfile = config['Files']['output']

seat_display = AirlineDisplay.new

seat_display.display(result,outfile)
