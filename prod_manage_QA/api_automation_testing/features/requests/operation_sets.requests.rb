class OperationSets_Requests

    def get_sets
        API.get('/operation-set')
    end

    def get_set_by_id(id)
        API.get('/operation-set/' + id.to_s)
    end

    def create_set(setName, operationRecords)
        API.post('/operation-set/', body: {
            "setName": setName,
            "operationRecords": operationRecords,
        }.to_json)
    end

    def update_set(id, setName, operationRecords)
        API.put('/operation-set/' + id.to_s, body: {
            "setName": setName,
            "operationRecords": operationRecords,
        }.to_json)
    end

    def delete_set(id)
        API.delete('/operation-set/' + id.to_s)
    end
    
end