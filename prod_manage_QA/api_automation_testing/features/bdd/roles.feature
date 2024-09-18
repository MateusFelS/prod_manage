@role
Feature: Roles Management
  As a system administrator
  I want to manage roles information
  So that I can create roles data efficiently

  Scenario: Registering a new role
    Given the user has permission to register new role
    When the user submits a valid registration form for a new role
    Then the system should successfully register the new role

  Scenario: Listing all roles
    Given the user has permission to access the role directory
    When the user requests the full list of roles
    Then the system should return a list of all registered roles

  Scenario: Listing role by ID
    Given the user has permission to view role details
    When the user requests the details of an role by their ID
    Then the system should return the roles information for the given ID