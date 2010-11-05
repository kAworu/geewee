Feature: Visit the blog
    In order to read the blog
    As a visitor
    I want browse posts

    Scenario: Posts list
        Given the blog has posts titled Geewee, Rails, Cucumber
        When  I go to the home page
        Then  I should see "Geewee"
        Then  I should see "Rails"
        Then  I should see "Cucumber"

