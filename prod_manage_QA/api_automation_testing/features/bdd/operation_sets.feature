@sets
Feature: Operation Sets Management
  As a system administrator
  I want to manage operation sets information
  So that I can create, update, delete, and retrieve operation sets data efficiently

  Scenario: Registering a new set
    Given the user has permission to register new sets
    When the user submits a valid registration form for a new set
    Then the system should successfully register the new set
  
  Scenario: Updating existing set information
    Given the user has permission to update operation sets
    When the user submits valid updates for an existing set
    Then the system should successfully update the operation sets

  Scenario: Deleting an set
    Given the user has permission to delete operation sets
    When the user initiates the deletion of an set record
    Then the system should permanently remove the set from the database

  Scenario: Listing all sets
    Given the user has permission to access the set directory
    When the user requests the full list of sets
    Then the system should return a list of all registered sets

  Scenario: Listing set by ID
    Given the user has permission to view set details
    When the user requests the details of an set by their ID
    Then the system should return the sets information for the given ID