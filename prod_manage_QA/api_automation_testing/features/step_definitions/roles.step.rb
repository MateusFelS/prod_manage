Given('the user has permission to register new role') do
    @create = Role_Requests.new
    @assert = Assertions.new
  end
  
  When('the user submits a valid registration form for a new role') do
    @create_role = @create.create_role(DATABASE[:role][:title], DATABASE[:role][:description])
  end
  
  Then('the system should successfully register the new role') do
    @assert.create_success(@create_role.code, @create_role.message)
  end
  
  Given('the user has permission to access the role directory') do
    @get = Role_Requests.new
    @assert = Assertions.new
  end
  
  When('the user requests the full list of roles') do
    @get_roles = @get.get_roles()
  end
  
  Then('the system should return a list of all registered roles') do
    @assert.request_success(@get_roles.code, @get_roles.message)
  end
  
  Given('the user has permission to view role details') do
    @get_by_id = Role_Requests.new
    @assert = Assertions.new
  end
  
  When('the user requests the details of an role by their ID') do
    @get_role_by_id = @get_by_id.get_role_by_id(DATABASE[:role][:id])
  end
  
  Then('the system should return the roles information for the given ID') do
    @assert.request_success(@get_role_by_id.code, @get_role_by_id.message)
  end

  Given('the user has permission to delete operation roles') do
    @delete = Role_Requests.new
    @assert = Assertions.new
  end
  
  When('the user initiates the deletion of an role record') do
    @delete_role = @delete.delete_role(DATABASE[:role][:id])
  end
  
  Then('the system should permanently remove the role from the database') do
    @assert.request_success(@delete_role.code, @delete_role.message)
  end