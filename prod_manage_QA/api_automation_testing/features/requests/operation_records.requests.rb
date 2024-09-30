class OperationRecods_Requests

    def get_operations
        API.get('/operations')
    end

    def get_operation_by_id(id)
        API.get('/operations/' + id.to_s)
    end

    def create_operation(operationName, calculatedTime)
        API.post('/operations/', body: {
            "operationName": operationName,
            "calculatedTime": calculatedTime,
        }.to_json)
    end

    def delete_operation(id)
        API.delete('/operations/' + id.to_s)
    end
    
end