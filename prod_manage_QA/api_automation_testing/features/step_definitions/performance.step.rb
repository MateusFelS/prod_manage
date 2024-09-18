Given('the user has permission to register new performance') do
    @create = Performance_Requests.new
  end
  
  When('the user submits a valid registration form for a new performance') do
    @create_performance = @create.create_performance(DATABASE[:performance][:employeeId], DATABASE[:performance][:date], DATABASE[:performance][:schedules],
    DATABASE[:performance][:produced], DATABASE[:performance][:meta])
  end
  
  Then('the system should successfully register the new performance') do
    @assert = expect(@create_performance.code).to eql(201)
  end

  Given('the user has permission to access the performance directory') do
    @get = Performance_Requests.new
    @assert = Assertions.new
  end
  
  When('the user requests the full list of performances') do
    @get_performances = @get.get_performances()
  end
  
  Then('the system should return a list of all registered performances') do
    @assert.request_success(@get_performances.code, @get_performances.message)
  end