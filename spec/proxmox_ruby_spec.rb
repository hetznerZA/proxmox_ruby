require "spec_helper"
require_relative '../lib/proxmox_ruby'

describe ProxmoxRuby::ConnectionFactory do
  let(:csrf_token) { "TOKEN"}
  let(:hostname) { "my.little.server" }
  let(:ticket) { "TICKET" }

  before(:each) do
    Faraday.stub(:new).and_yield(connection).and_return(connection)
  end

  describe "#get_tokens" do
    let(:connection) { double(Faraday::Connection, :post => response).as_null_object }
    let(:password) { "ho-hum" }
    let(:response) { double(Faraday::Response, :body => response_body) }
    let(:response_body) { JSON.generate({data:{ticket: ticket, CSRFPreventionToken: csrf_token}}) }
    let(:username) { "root@pam" }

    subject { described_class.new }

    it "instantiates a Faraday instance for the provided host" do
      Faraday.should_receive(:new).with(hash_including(url: "https://#{hostname}:8006", ssl: {verify: false}))

      subject.get_tokens hostname, username, password
    end

    it "sets the connection up submit data as a url-encoded form" do
      connection.should_receive(:request).with(:url_encoded)

      subject.get_tokens hostname, username, password
    end

    it "uses the default Faraday adapter" do
      connection.should_receive(:adapter).with(Faraday.default_adapter)

      subject.get_tokens hostname, username, password
    end

    it "requests a ticket" do
      connection.should_receive(:post).with("api2/json/access/ticket")

      subject.get_tokens hostname, username, password
    end

    it "passes the provided username and password as part of the ticket request" do
      request = double
      request.should_receive(:body=).with({username: username, password: password})
      connection.stub(:post).and_yield(request).and_return(response)

      subject.get_tokens hostname, username, password
    end

    it "stores the token that is returned" do
      subject.get_tokens hostname, username, password
      subject.ticket.should eql ticket
    end

    it "stores the CSRF token that is returned" do
      subject.get_tokens hostname, username, password
      subject.csrf_token.should eql csrf_token
    end

    it "stores the hostname for the connection" do
      subject.get_tokens hostname, username, password
      subject.hostname.should eql hostname
    end
  end

  describe "#build_connection" do
    let(:connection) { double(Faraday::Connection, :headers => headers).as_null_object }
    let(:headers) { {} }

    subject do
      factory = described_class.new
      factory.ticket = ticket
      factory.csrf_token = csrf_token
      factory.hostname = hostname
      factory
    end

    it "connects to the host" do
      Faraday.should_receive(:new).with(hash_including(url: "https://#{hostname}:8006", ssl: {verify: false}))

      subject.build_connection
    end

    it "sets the connection up submit data as a url-encoded form" do
      connection.should_receive(:request).with(:url_encoded)

      subject.build_connection
    end

    it "uses the default Faraday adapter" do
      connection.should_receive(:adapter).with(Faraday.default_adapter)

      subject.build_connection
    end

    it "sets the ticket as a cookie value for the connection" do
      subject.build_connection

      headers.should eql({ "Cookie" => "PVEAuthCookie=#{ticket}"})
    end

    it "returns the initialised connection" do
      subject.build_connection.should eql connection
    end
  end
end
