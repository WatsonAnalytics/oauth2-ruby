# Ruby on Rails example for IBM Watson Analytics

This code sample is a complete Ruby on Rails application built with Ruby 2.2.4 and Rails 4.2.5.2.  It should work with other versions, but the Gemfile may need to be adjusted. 

## Setup
1. Install the dependencies by entering the sample directory and running `bundle install`.
2. Register your client id and client secret. Use "http://localhost:3000/redirect" as your redirect URI. You only need to call this operation once unless the client ID changes. Use the following CURL command. Replace the details with your information.
```
curl -v -X PUT -H "X-IBM-Client-Secret:YOUR_CLIENT_SECRET" -H "X-IBM-Client-Id:YOUR_CLIENT_ID" -H "Content-Type: application/json" -d '{"clientName": "The Sample Outdoors Company", "redirectURIs": "http://localhost:3000/redirect", "ownerName": "John Smith", "ownerEmail": "John.Smith@example.com", "ownerCompany": "example.com", "ownerPhone": "555-123-4567"}' https://api.ibm.com/watsonanalytics/run/oauth2/v1/config
```
3. Create and edit a file called `application.yml` in the "config" folder that matches the following template. Enter your client id and secret. Save it in the application folder (where is the index.html file).
```
  		wa_client_id=YOUR_CLIENT_ID
  		wa_client_secret=YOUR_CLIENT_SECRET
```
4. Start Rails with `rails server`.
5. Open a web browser and navigate to this address: http://localhost:3000/.

## Notes
* For clarity, this sample application uses `localhost` as part of the URL for the application. However, when you create your own application, do not use localhost.
* This sample application is simplified to emphasize the code that you need to work with Watson Analytics. For example, it contains minimal error checking.
