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

# p nodes
#
# p node[:mem].to_f / node[:maxmem].to_f
# p node[:disk].to_f / node[:maxdisk].to_f
#
# p node[:node]

resp = connection.get("api2/json/nodes/#{node[:node]}/storage")
stor_list = JSON.parse(resp.body, symbolize_names: true)[:data]

puts "STORAGE LIST"
p stor_list

resp = connection.get("/api2/json/nodes/#{node[:node]}/qemu")

qemus = JSON.parse(resp.body, symbolize_names: true)[:data]

puts "QEMUS"
p qemus

inuse_vmids = qemus.map { |vm| vm[:vmid].to_i }

next_vmid = nil

until next_vmid do
  candidate_vmid = 101 + Random.rand(200)
  unless inuse_vmids.include? candidate_vmid
    next_vmid = candidate_vmid
    inuse_vmids << candidate_vmid
  end
end

p next_vmid

resp = connection.post("/api2/json/nodes/#{node[:node]}/storage/VM_USE/content") do |req|
  req.body = { vmid: next_vmid, filename: "vm-#{next_vmid}-disk-1", size:"8G"}
end

puts "STORAGE CREATE"
p resp.status
p resp.body

resp = connection.post("/api2/json/nodes/#{node[:node]}/qemu") do |req|
  req.body = { vmid: next_vmid, name: "rory.is.awesome", onboot: 1, ostype: "l26", net0: "virtio,bridge=vmbr0", virtio0: "volume=VM_USE:vm-#{next_vmid}-disk-1,cache=writeback" }
  # req.body = { vmid: next_vmid, name: "rory.is.awesome", onboot: 1, ostype: "l26", net0: "virtio,bridge=vmbr0", virtio0: "VM_USE:12,cache=writeback" }
  # onboot - start at boot
  # VM_USE:10 trick - found here http://forum.proxmox.com/threads/12059-API-Create-KVM-with-Logical-Volume
end

puts "VM CREATE"
p resp.status
p resp.body

resp = connection.get("/api2/json/nodes/#{node[:node]}/storage/VM_USE/content")

storage = JSON.parse(resp.body, symbolize_names: true)[:data]

p storage

