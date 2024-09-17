class Performance_Requests

    def create_performance(employeeId, date, schedules, produced, meta)
        API.post('/performance/', body: {
            "employeeId": employeeId,
            "date": date,
            "schedules": schedules,
            "produced": produced,
            "meta": meta
        }.to_json)
    end

    def get_performances
        API.get('/performance')
    end

end