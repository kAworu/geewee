Feature: reading the posts
    In order to learn something
    As a visitor
    I want to be able to read the posts

    Background:
        Given the blog is configured

    Scenario: seeing the post's title, author, date and intro in the homepage
        Given there is an author named "Agent Smith"
        And there is a post titled "Cookies" by "Agent Smith" published 2 days ago
        When I go to the homepage
        Then I should see "Cookies" in the content
        And I should see "published by" in the content
        And I should see "Agent Smith" in the content
        And I should see "two days ago" in the content
        And I should see the intro of the post "Cookies"
        And I should not see the body of the post "Cookies"

    Scenario: following the "read more" link
        Given there is a post titled "interesting post!"
        And I am on the homepage
        When I follow "read more..." in the content
        Then I should be on the post page "interesting post!"

    Scenario: following the title link
        Given there is a post titled "Nintendo"
        And I am on the homepage
        When I follow "Nintendo" in the content
        Then I should be on the post page "Nintendo"

    Scenario: reading the post's body
        Given there is a post titled "very long post"
        When I go to the post page "very long post"
        Then I should see "very long post" in the content
        And I should see the intro of the post "very long post"
        And I should see the body of the post "very long post"
