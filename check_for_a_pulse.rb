require "bundler"
require "faraday"
require 'json'

servername = ARGV[0]
username = ARGV[1]
password = ARGV[2]

connection = Faraday.new(url: "https://#{servername}:8006", ssl: {verify: false}) do |conn|
  conn.request  :url_encoded
  conn.adapter  Faraday.default_adapter
end

resp =  connection.post("/api2/json/access/ticket") do |req|
  req.body = { username: username, password: password }
end

data = JSON.parse(resp.body, symbolize_names: true)
p data[:data]
ticket = data[:data][:ticket]

connection = Faraday.new(url: "https://#{servername}:8006", ssl: {verify: false}) do |conn|
  conn.request  :url_encoded
  conn.headers["Cookie"] = "PVEAuthCookie=#{ticket}"
  conn.adapter  Faraday.default_adapter
end

resp = connection.get("/api2/json/nodes")

nodes = JSON.parse(resp.body, symbolize_names: true)[:data]

node = nodes.first

p node[:mem].to_f / node[:maxmem].to_f
p node[:disk].to_f / node[:maxdisk].to_f

resp = connection.get("/api2/json/nodes/#{node[:node]}/qemu")

qemus = JSON.parse(resp.body, symbolize_names: true)

p qemus
