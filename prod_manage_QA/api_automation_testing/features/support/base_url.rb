module API
    include HTTParty
    base_uri 'http://192.168.1.10:3000'
    format :json
    headers 'Content-Type': 'application/json'
end