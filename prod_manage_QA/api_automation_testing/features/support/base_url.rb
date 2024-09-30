module API
    include HTTParty
    base_uri '' # Coloque sua url base
    format :json
    headers 'Content-Type': 'application/json'
end