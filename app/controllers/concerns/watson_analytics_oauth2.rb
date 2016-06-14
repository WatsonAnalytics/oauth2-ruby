###############################################################################
#
# The MIT License (MIT)
#
# Copyright (c) 2016 IBM Corp.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
###############################################################################

module WatsonAnalyticsOauth2
  extend ActiveSupport::Concern
  
  def init_client
    @clientid = ENV['wa_client_id']
    @secret = ENV['wa_client_secret']
    @headers = {'X-IBM-Client-Id' => @clientid, 'X-IBM-Client-Secret' => @secret}
    @client = OAuth2Client::Client.new('https://api.ibm.com', 
       @clientid, 
       @secret, 
       {
           :authorize_path => 'https://api.ibm.com/watsonanalytics/run/clientauth/v1/auth',
           :token_path => 'https://api.ibm.com/watsonanalytics/run/oauth2/v1/token'
         }
       )
  end
  
  def get_connection
    if session[:wa_token]
      # Add the access token for authenticated API calls.
      @headers[:'Authorization'] = 'Bearer ' + session[:wa_token]
    end
    
    return Faraday.new("https://api.ibm.com") do |faraday|
      faraday.response :detailed_logger, config.logger
      faraday.adapter Faraday.default_adapter
    end
  end
end