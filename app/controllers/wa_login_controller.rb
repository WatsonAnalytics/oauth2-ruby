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

class WaLoginController < ApplicationController
  
  before_action :init_client
    
  def index
    # Generate URL to obtain OAuth2 authentication code
    @redirect_uri = 'http://' + request.host_with_port() + '/waLogin/redirect' 
    @auth_url = @client.authorization_code.authorization_path(:redirect_uri => @redirect_uri, :scope => 'userContext')
  end

  def redirect
    # Clear the session first
    reset_session
    
    # Request access token from /oauth2/v1/token
    token_response = @client.authorization_code.get_token(params[:code], {:headers => @headers})
    body = JSON.parse(token_response.body)
    access_token = body["access_token"]

    # Save the access token in the session
    session[:wa_token] = access_token
    @headers[:'Authorization'] = 'Bearer ' + session[:wa_token]
      
    connection = Faraday.new("https://api.ibm.com") do |faraday|
      faraday.response :detailed_logger, config.logger
      faraday.adapter Faraday.default_adapter
    end
    
    # Call the /accounts/v1/me endpoint - retrieve user information
    response = connection.get('/watsonanalytics/run/accounts/v1/me',{} , @headers)
    body = JSON.parse(response.body)
    @displayName = body["displayName"]
    @usage = body["tenantQuota"]["currentDiskUsage"]
    @quota = body["tenantQuota"]["maxDiskSpace"]
  end
  
  def upload
    if session[:wa_token]
      # Add the access token for authenticated API calls.
      @headers[:'Authorization'] = 'Bearer ' + session[:wa_token]
    end

    connection = Faraday.new("https://api.ibm.com") do |faraday|
      faraday.response :detailed_logger, config.logger
      faraday.adapter Faraday.default_adapter
    end
    
    # Create the data set
    response = connection.post do |request|
      request.url "/watsonanalytics/run/data/v1/datasets"
      request.headers = @headers
      request.headers['Content-Type'] = 'application/json'
      request.body = '{ "name" : "API Test Upload" }' 
    end

    body = JSON.parse(response.body)

    if response.success?
      id = body['id']
        
      # Segment the upload into max 25MB segments.
      response = connection.put do |request|
        request.url "/watsonanalytics/run/data/v1/datasets/#{id}/content/0001"
        request.headers = @headers
        request.headers['Content-Type'] = "text/csv"
        request.body = "A,B,C,D\n1,2,3,4\n4,3,2,1\n1,2,3,4\n" 
      end
      
      # Upload a second segment.
      response = connection.put do |request|
        request.url "/watsonanalytics/run/data/v1/datasets/#{id}/content/0002"
        request.headers = @headers
        request.headers['Content-Type'] = "text/csv"
        request.body = "1,2,3,4\n4,3,2,1\n1,2,3,4\n7,8,9,0\n" 
      end

      # PUT an empty response body to /content in order to start the upload
      response = connection.put do |request|
        request.url "/watsonanalytics/run/data/v1/datasets/#{id}/content"
        request.headers = @headers
        request.headers['Content-Type'] = 'text/csv'
      end
    else
      flash[:error] = "Failed to upload data: #{body['message']}"
    end    
  end
  
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
end
