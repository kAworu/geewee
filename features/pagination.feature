Feature: see and use the pagination
    In order to avoid having all posts on the home page
    As a visitor
    I want to be to use the pagination

    Background:
        Given the blog is configured
        Given the number of posts per page is 2
        And   there is a post titled "roses are red" from 1 day ago
        And   there is a post titled "violets are blue" from 12 days ago
        And   there is a post titled "Cucumber is sweet" from 30 days ago
        And   there is a post titled "and so are you" from 42 days ago
        And   there is a post titled "the first post" from 666 days ago

    Scenario: reading all the posts
        Given I am on the homepage
        Then  I should see "roses are red"
        And   I should see "violets are blue"
        And   I should not see "Cucumber is sweet"
        And   I should not see "and so are you"
        When  I go to the page 2
        Then  I should not see "roses are red"
        And   I should not see "violets are blue"
        And   I should see "Cucumber is sweet"
        And   I should see "and so are you"
        And   I should not see "the first post"
        When  I go to the page 3
        Then  I should not see "roses are red"
        And   I should not see "violets are blue"
        And   I should not see "Cucumber is sweet"
        And   I should not see "and so are you"
        And   I should see "the first post"

    Scenario: using the next and previous buttons
        Given I am on the homepage
        Then I should see "previous" within "div.pagination"
        Then I should see "next" within "div.pagination"
        When I follow "next" within "div.pagination"
        Then  I should be on the page 2
        When I follow "next" within "div.pagination"
        Then  I should be on the page 3
        When I follow "previous" within "div.pagination"
        Then  I should be on the page 2
        When I follow "previous" within "div.pagination"
        Then  I should be on the home page

    Scenario: using the numbered links for pagination
        Given I am on the homepage
        Then I should see "1" within "div.pagination"
        Then I should see "2" within "div.pagination"
        Then I should see "3" within "div.pagination"
        When I follow "2" within "div.pagination"
        Then  I should be on the page 2
        When I follow "3" within "div.pagination"
        Then  I should be on the page 3
        When I follow "1" within "div.pagination"
        Then  I should be on the home page

    Scenario: testing
        Given I am on the page 2
        Then I should be on the page 2
