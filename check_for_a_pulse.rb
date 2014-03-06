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
ticket = data[:data][:ticket]
csrfp_prevention_token =  data[:data][:CSRFPreventionToken]

connection = Faraday.new(url: "https://#{servername}:8006", ssl: {verify: false}) do |conn|
  conn.request  :url_encoded
  conn.headers["Cookie"] = "PVEAuthCookie=#{ticket}"
  conn.headers["CSRFPreventionToken"] = csrfp_prevention_token
  conn.adapter  Faraday.default_adapter
end

resp = connection.get("/api2/json/nodes")

nodes = JSON.parse(resp.body, symbolize_names: true)[:data]

node = nodes.first

puts "Nodes"
p nodes
#
# p node[:mem].to_f / node[:maxmem].to_f
# p node[:disk].to_f / node[:maxdisk].to_f
#
# p node[:node]

resp = connection.get("api2/json/nodes/#{node[:node]}/storage")
stor_list = JSON.parse(resp.body, symbolize_names: true)[:data]

puts "STORAGE LIST"
p stor_list

resp = connection.get("api2/json/cluster/nextid")
nextid = JSON.parse(resp.body, symbolize_names: true)[:data]

puts "Next id"
p nextid

resp = connection.get("/api2/json/nodes/#{node[:node]}/qemu")

qemus = JSON.parse(resp.body, symbolize_names: true)[:data]

puts "QEMUS"
p qemus

next_vmid = nextid

# resp = connection.post("/api2/json/nodes/#{node[:node]}/storage/VM_USE/content") do |req|
#   req.body = { vmid: next_vmid, filename: "vm-#{next_vmid}-disk-1", size:"8G"}
# end
# 
# puts "STORAGE CREATE"
# p resp.status
# p resp.body
# 
# resp = connection.post("/api2/json/nodes/#{node[:node]}/qemu") do |req|
#   # p req
#   # req.body = { vmid: next_vmid, name: "rory.is.awesome", onboot: 1, ostype: "l26", net0: "virtio,bridge=vmbr0", virtio0: "volume=VM_USE:vm-#{next_vmid}-disk-1,cache=writeback" }
#   # req.body = { vmid: next_vmid, name: "rory.is.awesome", onboot: 1, ostype: "l26", net0: "virtio,bridge=vmbr0", virtio0: "VM_USE:12,cache=writeback" }
#   # onboot - start at boot
#   # VM_USE:10 trick - found here http://forum.proxmox.com/threads/12059-API-Create-KVM-with-Logical-Volume
# end
# 
# puts "VM CREATE"
# p resp.status
# p resp.body
# 
resp = connection.get("/api2/json/nodes/#{node[:node]}/storage/VM_USE/content") do |req|
end

storage = JSON.parse(resp.body, symbolize_names: true)[:data]


puts "SPEC VM #100"
resp = connection.get("/api2/json/nodes/#{node[:node]}/qemu/100/config")

qemu_100 = JSON.parse(resp.body, symbolize_names: true)[:data]

p qemu_100

# puts "Cluster Resources"
# resp = connection.get("/api2/json/cluster/resources")
# 
# cluster_res = JSON.parse(resp.body, symbolize_names: true)[:data]
# 
# p cluster_res
