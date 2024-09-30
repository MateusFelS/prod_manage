Given('the user has permission to register new operations') do
    @create = OperationRecods_Requests.new
    @assert = Assertions.new
  end
  
  When('the user submits a valid registration form for a new operation') do
    @create_operation = @create.create_operation(DATABASE[:operation][:operationName], DATABASE[:operation][:calculatedTime])
  end
  
  Then('the system should successfully register the new operation') do
    @assert.create_success(@create_operation.code, @create_operation.message)
  end
  
  Given('the user has permission to access the operation directory') do
    @get = OperationRecods_Requests.new
    @assert = Assertions.new
  end
  
  When('the user requests the full list of operations') do
    @get_operations = @get.get_operations
  end
  
  Then('the system should return a list of all registered operations') do
    @assert.request_success(@get_operations.code, @get_operations.message)
  end
  
  Given('the user has permission to view operation details') do
    @get_by_id = OperationRecods_Requests.new
    @assert = Assertions.new
  end
  
  When('the user requests the details of an operation by their ID') do
    @get_operation_by_id = @get_by_id.get_operation_by_id((DATABASE[:operation][:id]))
  end
  
  Then('the system should return the operations information for the given ID') do
    @assert.request_success(@get_operation_by_id.code, @get_operation_by_id.message)
  end