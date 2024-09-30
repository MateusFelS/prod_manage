@employee
Feature: Employees Management
  As a system administrator
  I want to manage employee information
  So that I can create, update, delete, and retrieve employee data efficiently

  Scenario: Registering a new employee
    Given the user has permission to register new employees
    When the user submits a valid registration form for a new employee
    Then the system should successfully register the new employee
  
  Scenario: Updating existing employee information
    Given the user has permission to update employee profiles
    When the user submits valid updates for an existing employee
    Then the system should successfully update the employees profile

  Scenario: Deleting an employee
    Given the user has permission to delete employee accounts
    When the user initiates the deletion of an employee record
    Then the system should permanently remove the employee from the database

  Scenario: Listing all employees
    Given the user has permission to access the employee directory
    When the user requests the full list of employees
    Then the system should return a list of all registered employees

  Scenario: Listing employee by ID
    Given the user has permission to view employee details
    When the user requests the details of an employee by their ID
    Then the system should return the employees information for the given ID