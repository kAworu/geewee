Feature: see the blog
    In order to learn something
    As a visitor
    I want to be able to see the blog

    Background:
        Given the blog is configured
        And the blog's title is "Cucumber salad"
        And there is a post titled "roses are red"

    Scenario: reading the home page
        When I go to the home page
        Then I should see "Cucumber salad" within "#header"
        And I should see "roses are red" within ".entry-title"
        And I should see /atom feed/ within "#sidebar"
        And I should see "Pages" within "#sidebar"
        And I should see "Authors" within "#sidebar"
        And I should see "Categories" within "#sidebar"
        And I should see "Tags cloud" within "#sidebar"
        And I should see "Archives" within "#sidebar"
        And I should see "Cucumber salad" within "#footer"
        And I should see /powered by geewee/ within "#footer"
