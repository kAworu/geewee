Feature: configure the blog
    In order to use the blog
    As an author and admin
    I want to be guided through the configuration

    Scenario: being redirected to config help page
        Given the blog is not configured
        When I go to the home page
        Then I should be on the config page
        And I should see "Welcome to geewee!"
        And I should see "rake geewee:first_run"
        And I should not see "rake geewee:config"
        And I should not see "rake geewee:new_author"
        And I should not see "rake geewee:client"

    Scenario: being redirected to help index page
        Given the blog is configured
        And there is no posts
        When I go to the home page
        Then I should be on the help page
        And I should see "geewee help" as post title
        And I should see "geewee config"
        And I should see "JSON API reference"
        And I should see "client manual"

    Scenario: reading the config help
        Given the blog is configured
        And I am on the help page
        When I follow "geewee config"
        Then I should be on the config page
        And I should see "Welcome to geewee!"
        And I should see "rake geewee:first_run"
        And I should see "rake geewee:config"
        And I should see "rake geewee:new_author"
        And I should see "rake geewee:client"

    Scenario: reading the API reference
        Given the blog is configured
        And I am on the help page
        When I follow "JSON API reference"
        Then I should be on the api page
        And I should complete this scenario

    Scenario: reading the client manual
        Given the blog is configured
        And I am on the help page
        When I follow "client manual"
        Then I should be on the man page
        And I should complete this scenario
