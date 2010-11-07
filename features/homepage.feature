Feature: see the blog
    In order to learn something
    As a visitor
    I want to be able to see the blog

    Background:
        Given the blog is configured
        And the blog's title is "Cucumber salad"
        And there is a post titled "roses are red"

    Scenario: reading the homepage
        When I go to the homepage
        Then I should see "Cucumber salad" in the header
        And I should see "roses are red" in the content
        And I should see "atom feed" in the sidebar
        And I should see "Cucumber salad" in the footer
        And I should see "powered by geewee" in the footer
