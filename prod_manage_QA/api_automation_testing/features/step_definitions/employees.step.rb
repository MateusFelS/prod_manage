Given('the user has permission to register new employees') do
    @create = Employees_Requests.new
  end
  
  When('the user submits a valid registration form for a new employee') do
    @create_employee = @create.create_employee(DATABASE[:employee][:name], DATABASE[:employee][:role], DATABASE[:employee][:entryDate])
  end
  
  Then('the system should successfully register the new employee') do
    @assert = expect(@create_employee.code).to eql(201)
  end
  
  Given('the user has permission to update employee profiles') do
    @update = Employees_Requests.new
    @assert = Assertions.new
  end
  
  When('the user submits valid updates for an existing employee') do
    @update_employee = @update.update_employee(1, DATABASE[:employee][:name], DATABASE[:employee][:role], DATABASE[:employee][:entryDate])
  end
  
  Then('the system should successfully update the employees profile') do
    @assert.request_success(@update_employee.code, @update_employee.message)
  end
  
  Given('the user has permission to delete employee accounts') do
   @delete = Employees_Requests.new
   @assert = Assertions.new
  end
  
  When('the user initiates the deletion of an employee record') do
    @delete_employee = @delete.delete_employee(1)
  end
  
  Then('the system should permanently remove the employee from the database') do
    @assert.request_success(@delete_employee.code, @delete_employee.message)
  end
  
  Given('the user has permission to access the employee directory') do
    @get = Employees_Requests.new
    @assert = Assertions.new
  end
  
  When('the user requests the full list of employees') do
    @get_employees = @get.get_employees
  end
  
  Then('the system should return a list of all registered employees') do
    @assert.request_success(@get_employees.code, @get_employees.message)
  end
  
  Given('the user has permission to view employee details') do
    @get_by_id = Employees_Requests.new
    @assert = Assertions.new
  end
  
  When('the user requests the details of an employee by their ID') do
    @get_employee_by_id = @get_by_id.get_employee_by_id(2)
  end
  
  Then('the system should return the employees information for the given ID') do
    @assert.request_success(@get_employee_by_id.code, @get_employee_by_id.message)
  end
  