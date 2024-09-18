Given('the user has permission to register new cuts') do
    @create = CutRecods_Requests.new
end

When('the user submits a valid registration form for a new cut') do
  @create_cut = @create.create_cut(DATABASE[:cut][:code], DATABASE[:cut][:pieceAmount], DATABASE[:cut][:line1], DATABASE[:cut][:line2],
  DATABASE[:cut][:limiteDate], DATABASE[:cut][:comment], DATABASE[:cut][:supplier], DATABASE[:cut][:employeeId])
end

Then('the system should successfully register the new cut') do
  @assert = expect(@create_cut.code).to eql(201)
end

Given('the user has permission to update cut records') do
  @update = CutRecods_Requests.new
  @assert = Assertions.new
end

When('the user submits valid updates for an existing cut') do
  @update_cut = @update.update_cut(1, DATABASE[:cut][:code], DATABASE[:cut][:pieceAmount], DATABASE[:cut][:line1], DATABASE[:cut][:line2],
  DATABASE[:cut][:limiteDate], DATABASE[:cut][:comment], DATABASE[:cut][:supplier], DATABASE[:cut][:employeeId])
end

Then('the system should successfully update the cut records') do
  @assert.request_success(@update_cut.code, @update_cut.message)
end

Given('the user has permission to delete cut records') do
  @delete = CutRecods_Requests.new
  @assert = Assertions.new
end

When('the user initiates the deletion of an cut record') do
  @delete_cut = @delete.delete_cut(4)
end

Then('the system should permanently remove the cut from the database') do
  @assert.request_success(@delete_cut.code, @delete_cut.message)
end

Given('the user has permission to access the cut directory') do
  @get = CutRecods_Requests.new
  @assert = Assertions.new
end

When('the user requests the full list of cuts') do
  @get_cuts = @get.get_cuts
end

Then('the system should return a list of all registered cuts') do
  @assert.request_success(@get_cuts.code, @get_cuts.message)
end

Given('the user has permission to view cut details') do
  @get_by_id = CutRecods_Requests.new
  @assert = Assertions.new
end

When('the user requests the details of an cut by their ID') do
  @get_cut_by_id = @get_by_id.get_cut_by_id(1)
end

Then('the system should return the cuts information for the given ID') do
  @assert.request_success(@get_cut_by_id.code, @get_cut_by_id.message)
end