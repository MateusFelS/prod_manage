@cut
Feature: Cut Records Management
  As a system administrator
  I want to manage cut records information
  So that I can create, update, delete, and retrieve cut records data efficiently

  Scenario: Registering a new cut
    Given the user has permission to register new cuts
    When the user submits a valid registration form for a new cut
    Then the system should successfully register the new cut
  
  Scenario: Updating existing cut information
    Given the user has permission to update cut records
    When the user submits valid updates for an existing cut
    Then the system should successfully update the cut records

  Scenario: Deleting an cut record
    Given the user has permission to delete cut records
    When the user initiates the deletion of an cut record
    Then the system should permanently remove the cut from the database

  Scenario: Listing all cuts
    Given the user has permission to access the cut directory
    When the user requests the full list of cuts
    Then the system should return a list of all registered cuts

  Scenario: Listing cut by ID
    Given the user has permission to view cut details
    When the user requests the details of an cut by their ID
    Then the system should return the cuts information for the given ID