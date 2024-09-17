@performance
Feature: Performance Management
  As a system administrator
  I want to manage performance information
  So that I can create performance data efficiently

  Scenario: Registering a new performance
    Given the user has permission to register new performance
    When the user submits a valid registration form for a new performance
    Then the system should successfully register the new performance

    Scenario: Listing all performances
    Given the user has permission to access the performance directory
    When the user requests the full list of performances
    Then the system should return a list of all registered performances