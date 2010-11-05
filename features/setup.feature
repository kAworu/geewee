Feature: configure the blog
    In order to use the blog
    As an author and admin
    I want to be guided through the configuration

    Scenario: just starting up
        Given The blog is not configured
        When I go to the home page
        Then I should be redirected to the config page
        And  I should see "welcome to geewee!"
        And  I should see "rake geewee:first_run"
