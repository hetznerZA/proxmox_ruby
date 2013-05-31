require "proxmox_ruby/version"
require "bundler"
require "faraday"
require "json"

module ProxmoxRuby
  class ConnectionFactory
    attr_accessor :ticket, :csrf_token, :hostname

    def get_tokens(hostname, username, password)
      @hostname = hostname

      c = Faraday.new(url: "https://#{hostname}:8006", ssl: {verify: false}) do |conn|
        conn.request :url_encoded
        conn.adapter Faraday.default_adapter
      end

      ticket_response = c.post("api2/json/access/ticket") do |req|
        req.body = {username: username, password: password}
      end

      response_hash = JSON.parse(ticket_response.body, :symbolize_names => true)[:data]

      @ticket = response_hash[:ticket]
      @csrf_token = response_hash[:CSRFPreventionToken]
    end

    def build_connection
      c = Faraday.new(url: "https://#{hostname}:8006", ssl: {verify: false}) do |conn|
        conn.request :url_encoded
        conn.headers["Cookie"] = "PVEAuthCookie=#{ticket}"
        conn.headers["CSRFPreventionToken"] = csrf_token
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
