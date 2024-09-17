
Given('that the user has permission to create new accounts') do
    @create = Users_Requests.new
  end
  
  When('the user submits a valid user registration form') do
    @create_user = @create.create_user(DATABASE[:user][:token], DATABASE[:user][:password], DATABASE[:user][:name])
  end
  
  Then('the system should create a new user account') do
    @assert = expect(@create_user.code).to eql(201)
  end
  
  Given('that the user has permission to edit user profiles') do
    @update = Users_Requests.new
    @assert = Assertions.new
  end
  
  When('the user submits a valid update request for an existing user') do
    @update_user = @update.update_user(1, DATABASE[:user][:password], DATABASE[:user][:name])
  end
  
  Then('the system should update the users information in the database') do
    @assert.request_success(@update_user.code, @update_user.message)
  end
  
  Given('that the user has permission to remove accounts') do
    @delete = Users_Requests.new
    @assert = Assertions.new
  end
  
  When('the user initiates the deletion of a user account') do
    @delete_user = @delete.delete_user(18)
  end
  
  Then('the system should permanently remove the users data from the database') do
    @assert.request_success(@delete_user.code, @delete_user.message)
  end

  Given('that the user has permission to access the user list') do
    @get = Users_Requests.new
    @assert = Assertions.new
  end
  
  When('the user performs a search on the user list') do
    @users_list = @get.get_users
  end
  
  Then('the system should return a list of users') do
    @assert.request_success(@users_list.code, @users_list.message)
  end
  
  Given('that the user has permission to view multiple user records') do
    @get_by_id = Users_Requests.new
    @assert = Assertions.new
  end
  
  When('the user requests a list of users ordered by their IDs') do
    @get_user_by_id = @get_by_id.get_user_by_id(1)
  end
  
  Then('the system should return a paginated list of users sorted by ID') do
    @assert.request_success(@get_user_by_id.code, @get_user_by_id.message)
  end