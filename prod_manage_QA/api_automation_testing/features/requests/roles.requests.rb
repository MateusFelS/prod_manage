class Role_Requests

    def create_role(title, description)
        API.post('/roles/', body: {
           "title": title,
           "description": description
        }.to_json)
    end

    def get_roles
        API.get('/roles')
    end

    def get_role_by_id(id)
        API.get('/roles/' + id.to_s)
    end

    def delete_role(id)
        API.delete('/roles/' + id.to_s)
    end
    
end