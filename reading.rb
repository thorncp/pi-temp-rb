class Reading
  attr_accessor(
    :voltage,
    :temperature_celsius,
    :temperature_fahrenheit,
    :read_at,
  )

  def initialize(attrs = {})
    attrs.each do |name, value|
      send("#{name}=", value)
    end
  end
end
