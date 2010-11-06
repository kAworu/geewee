Feature: see and use the pagination
    In order to avoid having all posts on the home page
    As a visitor
    I want to be to use the pagination

    Background:
        Given the blog is configured
        And the number of posts per page is 2
        And there is 5 published posts

    Scenario: reading all the posts
        When I go to the home page
        Then I should see the posts 1 and 2
        And I should not see the posts 3, 4 and 5
        When I go to the page 2
        Then I should see the posts 3 and 4
        And I should not see the posts 1, 2 and 5
        When I go to the page 3
        Then I should see the post 5
        And I should not see the posts 1, 2, 3 and 4

    Scenario: using the next and previous buttons
        Given I am on the homepage
        Then I should see "previous" within "div.pagination"
        And I should see "next" within "div.pagination"
        When I follow "next" within "div.pagination"
        Then I should be on the page 2
        When I follow "next" within "div.pagination"
        Then I should be on the page 3
        When I follow "previous" within "div.pagination"
        Then I should be on the page 2
        When I follow "previous" within "div.pagination"
        Then I should be on the page 1

    Scenario: using the numbered links for pagination
        Given I am on the homepage
        Then I should see "1" within "div.pagination"
        And I should see "2" within "div.pagination"
        And I should see "3" within "div.pagination"
        When I follow "2" within "div.pagination"
        Then I should be on the page 2
        When I follow "1" within "div.pagination"
        Then I should be on the page 1
        When I follow "3" within "div.pagination"
        Then I should be on the page 3
