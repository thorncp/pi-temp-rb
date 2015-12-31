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

  STATS_INTERVAL = 60 * 60 # hourly
  STATS_CUTOFF = 60 * 60 * 24 * 7 # past week

  STATS_STATEMENT = <<-SQL
    SELECT
      avg(voltage) AS avereage_voltage,
      avg(celsius) AS avereage_celsius,
      avg(fahrenheit) AS avereage_fahrenheit,
      round(read_at / :interval) * :interval AS read_at_interval
    FROM
      temperature_readings
    WHERE
      read_at > strftime('%s', 'now') - :cutoff
    GROUP BY
      read_at_interval
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
      row_to_reading(row)
    end
  end

  def stats(interval: STATS_INTERVAL, cutoff: STATS_CUTOFF)
    @db.execute(
      STATS_STATEMENT,
      interval: interval,
      cutoff: cutoff,
    ).map do |row|
      row_to_reading(row)
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

  def row_to_reading(row)
    Reading.new(
      voltage: row[0],
      temperature_celsius: row[1],
      temperature_fahrenheit: row[2],
      read_at: Time.at(row[3]),
    )
  end
end
