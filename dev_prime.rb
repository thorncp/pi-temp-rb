require_relative "database"

database = Database.new

20.times do |offset|
  voltage = (0.69..0.73).step(0.005).to_a.sample
  celsius = (voltage - 0.5) * 100.0
  fahrenheit = (celsius * 9.0 / 5.0) + 32.0

  reading = Reading.new(
    voltage: voltage,
    temperature_celsius: celsius,
    temperature_fahrenheit: fahrenheit,
    read_at: Time.now - offset * 60,
  )

  database.insert(reading)
end

database.stats(interval: 60).each do |reading|
  p reading
end
