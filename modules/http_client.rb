# 
# Copyright (C) 2010-2012 Kyle Johnson <kyle@vacantminded.com>, Alex Iadicicco
# (http://terminus-bot.net/)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 

require 'net/http'
require "uri"

module Bot

  MODULE_LOADED_HTTP  = true
  MODULE_VERSION_HTTP = 0.1

  def self.http_get(uri, limit = Config[:modules][:http_client][:redirects], redirected = false)
    return nil if limit == 0

    response = Net::HTTP.start(uri.host, uri.port,
                               :use_ssl => uri.scheme == "https",
                               :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

      http.request Net::HTTP::Get.new(uri.request_uri)
    
    end

    case response

    when Net::HTTPSuccess
      return :response => response, :hostname => uri.hostname, :redirected => redirected

    when Net::HTTPRedirection
      location = URI(response['location'])

      $log.debug("Bot.http_get") { "Redirection: #{uri} -> #{location} (#{limit})" }

      return http_get(location, limit - 1, true)

    else
      return nil

    end
  end
end
