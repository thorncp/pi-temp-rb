require "sinatra"
require_relative "reading"
require_relative "database"

if settings.environment == :production
  set port: 80
end

get "/" do
  readings = Database.new.stats
  erb :index, locals: { readings: readings }
end
