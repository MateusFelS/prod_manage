class Employees_Requests

    def get_employees
        API.get('/employees')
    end

    def get_employee_by_id(id)
        API.get('/employees/' + id.to_s)
    end

    def create_employee(name, role, entryDate)
        API.post('/employees/', body: {
            "name": name,
            "role": role,
            "entryDate": entryDate
        }.to_json)
    end

    def update_employee(id, name, role, entryDate)
        API.put('/employees/' + id.to_s, body: {
            "name": name,
            "role": role,
            "entryDate": entryDate
        }.to_json)
    end

    def delete_employee(id)
        API.delete('/employees/' + id.to_s)
    end
    
end