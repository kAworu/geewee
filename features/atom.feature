Feature: atom feed
    In order to be alerted when a new comment or post is created
    As a visitor
    I want to be able to follow the blog and posts via atom feed

    Background:
        Given the blog is configured

    Scenario: following the blog's atom feed
        Given I am on the homepage
        When I follow "atom feed" in the sidebar
        Then I should be on the blog atom feed page

    Scenario: following a post's atom feed
        Given there is a post titled "Atom iz good"
        And I am on the post page "Atom iz good"
        When I follow "atom feed" in the content
        Then I should be on the post "Atom iz good" atom feed page
