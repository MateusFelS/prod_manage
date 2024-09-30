Given('the user has permission to register new sets') do
    @create = OperationSets_Requests.new
    @assert = Assertions.new
  end
  
  When('the user submits a valid registration form for a new set') do
    @create_set = @create.create_set(DATABASE[:operation_set][:setName], DATABASE[:operation_set][:operationRecords])
  end
  
  Then('the system should successfully register the new set') do
    @assert = @assert.create_success(@create_set.code, @create_set.message)
  end
  
  Given('the user has permission to update operation sets') do
    @update = OperationSets_Requests.new
    @assert = Assertions.new
  end
  
  When('the user submits valid updates for an existing set') do
    @update_set = @update.update_set(DATABASE[:operation_set][:id], DATABASE[:operation_set][:setName], DATABASE[:operation_set][:operationRecords])
  end
  
  Then('the system should successfully update the operation sets') do
    @assert = @assert.request_success(@update_set.code, @update_set.message)
  end
  
  Given('the user has permission to access the set directory') do
    @get = OperationSets_Requests.new
    @assert = Assertions.new
  end
  
  When('the user requests the full list of sets') do
    @get_sets = @get.get_sets
  end
  
  Then('the system should return a list of all registered sets') do
    @assert.request_success(@get_sets.code, @get_sets.message)
  end
  
  Given('the user has permission to view set details') do
    @get_by_id = OperationSets_Requests.new
    @assert = Assertions.new
  end
  
  When('the user requests the details of an set by their ID') do
    @get_set_by_id = @get_by_id.get_set_by_id(DATABASE[:operation_set][:id])
  end
  
  Then('the system should return the sets information for the given ID') do
    @assert.request_success(@get_set_by_id.code, @get_set_by_id.message)
  end

  Given('the user has permission to delete operation sets') do
    @delete = OperationSets_Requests.new
    @assert = Assertions.new
  end
  
  When('the user initiates the deletion of an set record') do
    @delete_set = @delete.delete_set(DATABASE[:operation_set][:id])
  end
  
  Then('the system should permanently remove the set from the database') do
    @assert.request_success(@delete_set.code, @delete_set.message)
  end