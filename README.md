# proxmox\_ruby

Provide an interface to the proxmox API

## Usage

At present, all you get is a Faraday::Connection instance, with the appropriate
auth ticket set - usage is clunky but as follows:

    require 'proxmox_ruby'

    fact = ProxmoxRuby::ConnectionFactory.new

    fact.get_tokens "proxmox_host.test.com","root@pam","my_secret_password"

    connection = fact.build_connection

    resp = connection.get("/api2/json/nodes") # resp is an instance of Faraday::Response

## Licence

proxmox\_ruby is licenced under the MIT licence.

The MIT License (MIT)

Copyright (c) 2013 Hetzner South Africa

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
