@operation
Feature: Operation Management
  As a system administrator
  I want to manage operation operation information
  So that I can create, update, delete, and retrieve operation operation data efficiently

  Scenario: Registering a new operation
    Given the user has permission to register new operations 
    When the user submits a valid registration form for a new operation
    Then the system should successfully register the new operation

  Scenario: Listing all operations
    Given the user has permission to access the operation directory
    When the user requests the full list of operations
    Then the system should return a list of all registered operations

  Scenario: Listing operation by ID
    Given the user has permission to view operation details
    When the user requests the details of an operation by their ID
    Then the system should return the operations information for the given ID