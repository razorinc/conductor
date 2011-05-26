Feature: Manage Pools
  In order to manage my cloud infrastructure
  As a user
  I want to manage my pools

  Background:
    Given I am an authorised user
    And I am logged in

  Scenario: Create a new Pool
    Given I am on the pools page
    And there is not a pool named "mockpool"
    When I follow "New Pool"
    Then I should be on the new pool page
    And I should see "Create a new Pool"
    When I fill in "pool_name" with "mockpool"
    And I select "default" from "pool_pool_family_id"
    And I fill in "quota_instances" with "unlimited"
    And I press "Save"
    Then I should be on the pool page
    And I should see "mockpool Pool"
    And I should have a pool named "mockpool"

  Scenario: Create a new Pool over XHR
    Given I request XHR
    And I am on the new pool page
    Then I should get back a partial
    And I should see "Create a new Pool"
    When I fill in "pool_name" with "mockpool"
    And I select "default" from "pool_pool_family_id"
    And I fill in "quota_instances" with "unlimited"
    And I press "Save"
    Then I should get back a partial
    And I should see "mockpool"

  @tag
  Scenario: View Pool's Quota Usage
    Given I have Pool Creator permissions on a pool named "mockpool"
    And the "mockpool" Pool has a quota with following capacities:
    | resource                  | capacity |
    | maximum_running_instances | 10       |
    | running_instances         | 8        |
    And I am on the pools page
    Then I should see the following:
    | mockpool | Deployments: 0	| Instances: 0 | Pending: 0	| Failed: 0	| Instance quota usage: 80 |

  Scenario: Enter invalid characters into Name field
    Given I am on the new pool page
    When I fill in "pool[name]" with "@%&*())_@!#!"
    And I press "Save"
    Then I should see "Name must only contain: numbers, letters, spaces, '_' and '-'"

  Scenario: Delete pools
    Given I am on the pools page
    And a pool "Amazon Startrek Pool" exists
    And a pool "Redhat Voyager Pool" exists
    When I go to the pools page
    And I follow "Filter View"
    Then there should be 3 pools
    When I check "Redhat Voyager Pool" pool
    And I check "Amazon Startrek Pool" pool
    And I press "Destroy"
    Then there should only be 1 pools
    And I should be on the pools page
    When I go to the pools page
    Then I should not see "Redhat Voyager Pool"
    And I should not see "Amazon Startrek Pool"

  Scenario: Create multiple pools
    Given I am on the pools page
    And there is not a pool named "mockpool"
    And there is not a pool named "foopool"
    When I follow "Filter View"
    And I follow "New Pool"
    Then I should be on the new pool page
    And I should see "Create a new Pool"
    When I fill in "pool_name" with "mockpool"
    And I select "default" from "pool_pool_family_id"
    And I press "Save"
    Then I should be on the pool page
    And I should see "Pool added"
    And I should see "mockpool"
    And I should have a pool named "mockpool"
    When I go to the pools page
    And I follow "Filter View"
    And I follow "New Pool"
    Then I should be on the new pool page
    And I should see "Create a new Pool"
    When I fill in "pool_name" with "foopool"
    And I select "default" from "pool_pool_family_id"
    And I press "Save"
    Then I should be on the pool page
    And I should see "Pool added"
    And I should have a pool named "mockpool"
    And I should have a pool named "foopool"

  Scenario: Cannot delete default_pool
    Given I am on the pools page
    When I follow "Filter View"
    And I check "default_pool" pool
    And I press "Destroy"
    Then I should see "The default pool cannot be deleted"
    And I should see "default_pool"

  Scenario: Cannot delete default_pool by renaming it
    Given I renamed default_pool to pool_default
    And I am on the pools page
    When I follow "Filter View"
    And I check "pool_default" pool
    And I press "Destroy"
    Then I should see "The default pool cannot be deleted"
    And I should see "pool_default"

  Scenario: View all pools in JSON format
    Given there are 2 pools
    And I accept JSON
    When I go to the pools page
    Then I should see 2 pools in JSON format

  Scenario: View all pools over XHR
    Given there are 2 pools
    And I request XHR
    When I go to the pools page
    Then I should get back a partial

  Scenario: View a pool in JSON format
    Given a pool "mockpool" exists
    And I accept JSON
    When I am viewing the pool "mockpool"
    Then I should see pool "mockpool" in JSON format

  Scenario: View a pool over XHR
    Given a pool "mockpool42" exists with deployment "mockdeployment"
    And I request XHR
    When I am viewing the pool "mockpool42"
    Then I should get back a partial
    And I should see "mockdeployment"

  Scenario: View a pool in filter view over XHR
    Given a pool "mockpool42" exists with deployment "mockdeployment"
    And I request XHR
    When I go to the "mockpool42" pool filter view page
    Then I should get back a partial
    And I should see "Deployment Name"
    And I should see "mockdeployment"

  Scenario: Create a pool and get JSON response
    Given I accept JSON
    When I create a pool
    Then I should get back a pool in JSON format

  Scenario: Delete a pool
    Given a pool "mockpool" exists
    And I accept JSON
    When I delete "mockpool" pool
    Then I should get back JSON object with success and errors

  Scenario: Switch pretty view to filtred view on pools index
    Given I am on the pools page
    And I see "Overview"
    And I should see "expand all"
    When I follow "Filter View"
    Then I should see "Pools" within "#details-view"
    And I should see "Instances" within "#details-view"
    And I should see "Deployments" within "#details-view"
    And I should not see "expand all"
    When I follow "Pretty View"

  Scenario: Switch from filtred view to pretty view on pools index
    Given I am on the pools page
    And I follow "Filter View"
    And I should see "Pools" within "#view"
    When I follow "Pretty View"
    Then I should not see "Pools" within "#view"
    And I should see "expand all"

  Scenario: Display alerts
    Given There is a mock pulp repository
    And there is a "fail1" failed instance
    When I go to the pools page
    Then I should see "Alerts"
    And I should see "fail1: error"

  Scenario: Pools#show pretty view
    Given a pool "mockpool" exists with deployment "mockdeployment"
    When I am viewing the pool "mockpool"
    And I follow "Pretty View"
    Then I should see "0 Instances" within "#view"

  Scenario: Pools#show filter view
    Given a pool "mockpool" exists with deployment "mockdeployment"
    When I am viewing the pool "mockpool"
    And I follow "Filter View"
    Then I should not see "0 Instances" within "#view"
