class CutRecods_Requests

    def get_cuts
        API.get('/cut-records')
    end

    def get_cut_by_id(id)
        API.get('/cut-records/' + id.to_s)
    end

    def create_cut(code, pieceAmount, line1, line2, limiteDate, comment, supplier, selectedOperations)
        API.post('/cut-records/', body: {
            "code": code,
            "pieceAmount": pieceAmount,
            "line1": line1,
            "line2": line2,
            "limiteDate": limiteDate,
            "comment": comment,
            "supplier": supplier,
            "selectedOperations": selectedOperations
        }.to_json)
    end

    def update_cut(id, code, pieceAmount, line1, line2, limiteDate, comment, supplier, selectedOperations)
        API.put('/cut-records/' + id.to_s, body: {
            "code": code,
            "pieceAmount": pieceAmount,
            "line1": line1,
            "line2": line2,
            "limiteDate": limiteDate,
            "comment": comment,
            "supplier": supplier,
            "selectedOperations": selectedOperations
        }.to_json)
    end

    def delete_cut(id)
        API.delete('/cut-records/' + id.to_s)
    end
    
end