class Users_Requests

    def get_users
        API.get('/users')
    end

    def get_user_by_id(id)
        API.get('/users/' + id.to_s)
    end

    def create_user(token, password, name)
        API.post('/users/', body: {
            "token": token,
            "password": password,
            "name": name
        }.to_json)
    end

    def update_user(id, password, name)
        API.put('/users/' + id.to_s, body: {
            "password": password,
            "name": name
        }.to_json)
    end

    def delete_user(id)
        API.delete('/users/' + id.to_s)
    end
    
end