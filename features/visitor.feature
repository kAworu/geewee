Feature: Visit the blog
    In order to read the blog
    As a visitor
    I want to browse posts

    Scenario: Posts list
        Given the blog is configured
        And   the blog has an author named "Me"
        And   the blog has a category named "stuff"
        And   the blog has a published post titled "Geewee" from 1 days ago
        And   the blog has a published post titled "Rails" from 3 days ago
        And   the blog has a published post titled "Cucumber" from 2 days ago
        When  I go to the home page
        Then  show me the page
        And   I should see "Geewee"
        And   I should see "Cucumber"
        And   I should not see "Rails"
