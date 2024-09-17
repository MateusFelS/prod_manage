class OperationRecods_Requests

    def get_operations
        API.get('/operations')
    end

    def get_operation_by_id(id)
        API.get('/operations/' + id.to_s)
    end

    def create_operation(cutType, operationName, calculatedTime)
        API.post('/operations/', body: {
            "cutType": cutType,
            "operationName": operationName,
            "calculatedTime": calculatedTime,
        }.to_json)
    end
    
end