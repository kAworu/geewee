Feature: read the geewee help pages
    In order to use the blog
    As an author and admin
    I want to be guided through the configuration and to have help pages

    Scenario: being redirected to config help page
        Given the blog is not configured
        When I go to the homepage
        Then I should be on the config page
        And I should see "Welcome to geewee!"
        And I should see "geewee is not configured" in the content
        And I should see "rake geewee:first_run" in the content

    Scenario: being redirected to help index page
        Given the blog is configured
        And there is no posts
        When I go to the homepage
        Then I should be on the help page
        And I should see "geewee help" in the content
        And I should see "geewee config" in the content
        And I should see "JSON API reference" in the content
        And I should see "client manual" in the content
        And I should see "geewee development" in the content

    Scenario: reading the config help
        Given the blog is configured
        And I am on the help page
        When I follow "geewee config"
        Then I should be on the config page
        And I should see "geewee is configured"
        And I should see "rake geewee:first_run" in the content
        And I should see "rake geewee:config" in the content
        And I should see "rake geewee:new_author" in the content
        And I should see "rake geewee:client" in the content

    Scenario: reading the API reference
        Given the blog is configured
        And I am on the help page
        When I follow "JSON API reference"
        Then I should be on the api page

    Scenario: reading the client manual
        Given the blog is configured
        And I am on the help page
        When I follow "client manual"
        Then I should be on the man page

    Scenario: reading the geewee development help
        Given the blog is configured
        And I am on the help page
        When I follow "geewee development"
        Then I should be on the development page
        And I should see "setting up the test and cucumber database" in the content
        And I should see "RAILS_ENV=test rake db:migrate" in the content
        And I should see "RAILS_ENV=test rake gems:install" in the content
        And I should see "RAILS_ENV=cucumber rake gems:install" in the content
