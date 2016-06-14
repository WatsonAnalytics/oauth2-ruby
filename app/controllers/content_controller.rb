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

class ContentController < ApplicationController
  include WatsonAnalyticsOauth2
  
  before_action :init_client

  def index
    connection = get_connection
    response = connection.get("/watsonanalytics/run/content/v1/folders",{} , @headers)
    @folder = JSON.parse(response.body)
  end

  def show
    connection = get_connection
    response = connection.get("/watsonanalytics/run/content/v1/folders/#{params[:id]}",{} , @headers)
    if response.success?
      body = JSON.parse(response.body)
      @folder = body['children']
    else
      @folder = JSON.parse('[]')
      @error = response.body  
    end
  end
  
  def dataset
    connection = get_connection
    response = connection.get("/watsonanalytics/run/data/v1/datasets/#{params[:id]}",{} , @headers)
    @dataset = JSON.parse(response.body)
    @parent = @dataset['folder']['id']
    response = connection.get("/watsonanalytics/run/data/v1/datasets/#{params[:id]}/job",{} , @headers)
    @status = JSON.parse(response.body)
  end
end
