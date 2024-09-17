@user
Feature: User Management
  As a system administrator
  I want to manage user information
  So that I can create, update, delete, and retrieve user data efficiently

  Scenario: Creating a new user
    Given that the user has permission to create new accounts
    When the user submits a valid user registration form
    Then the system should create a new user account

  Scenario: Updating existing user information
    Given that the user has permission to edit user profiles
    When the user submits a valid update request for an existing user
    Then the system should update the users information in the database

  Scenario: Deleting a user account
    Given that the user has permission to remove accounts
    When the user initiates the deletion of a user account
    Then the system should permanently remove the users data from the database

  Scenario: Listing all users
    Given that the user has permission to access the user list
    When the user performs a search on the user list
    Then the system should return a list of users

  Scenario: Listing users by ID
    Given that the user has permission to view multiple user records
    When the user requests a list of users ordered by their IDs
    Then the system should return a paginated list of users sorted by ID

