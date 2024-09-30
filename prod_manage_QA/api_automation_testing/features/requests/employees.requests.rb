class Employees_Requests

    def get_employees
        API.get('/employees')
    end

    def get_employee_by_id(id)
        API.get('/employees/' + id.to_s)
    end

    def create_employee(name, roleId, entryDate)
        API.post('/employees/', body: {
            "name": name,
            "roleId": roleId,
            "entryDate": entryDate
        }.to_json)
    end

    def update_employee(id, name, roleId, entryDate)
        API.put('/employees/' + id.to_s, body: {
            "name": name,
            "roleId": roleId,
            "entryDate": entryDate
        }.to_json)
    end

    def delete_employee(id)
        API.delete('/employees/' + id.to_s)
    end
    
end