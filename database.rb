require "sqlite3"
require_relative "reading"

class Database
  def initialize(path = "temps.db")
    @db = SQLite3::Database.new(path)
    build_schema_if_needed
  end

  INSERT_STATEMENT = <<-SQL
    INSERT INTO temperature_readings (
      voltage,
      celsius,
      fahrenheit,
      read_at
    ) VALUES (?, ?, ?, ?)
  SQL

  SELECT_STATEMENT = <<-SQL
    SELECT
      voltage,
      celsius,
      fahrenheit,
      read_at
    FROM
      temperature_readings
  SQL

  def insert(reading)
    @db.execute(
      INSERT_STATEMENT,
      reading.voltage,
      reading.temperature_celsius,
      reading.temperature_fahrenheit,
      reading.read_at.to_i,
    )
  end

  def all
    @db.execute(SELECT_STATEMENT).map do |row|
      Reading.new(
        voltage: row[0],
        temperature_celsius: row[1],
        temperature_fahrenheit: row[2],
        read_at: Time.at(row[3]),
      )
    end
  end

  private

  def build_schema_if_needed
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS temperature_readings (
        voltage REAL,
        celsius REAL,
        fahrenheit REAL,
        read_at DATETIME
      )
    SQL
  end
end
