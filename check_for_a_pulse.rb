require "bundler"
require "faraday"

servername = ARGV[0]
username = ARGV[1]
password = ARGV[2]

connection = Faraday.new(url: "https://#{servername}:8006", ssl: {verify: false}) do |conn|
  conn.request  :multipart
  conn.request  :url_encoded
  conn.adapter  Faraday.default_adapter
end

resp =  connection.post("/api2/json/access/ticket") do |req|
  req.body = { "username" => username, "password" => password }
end

p resp.status
p resp.body
