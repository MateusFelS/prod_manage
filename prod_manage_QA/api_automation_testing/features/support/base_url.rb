module API
    include HTTParty
    base_uri 'https://prod-manage-backend.onrender.com' # Coloque sua url base
    format :json
    headers 'Content-Type': 'application/json'
end