Feature: browse the archives by month of the year
    In order to only see recent or old posts
    As a visitor
    I want to browse the posts by date

    Background:
        Given the blog is configured

    Scenario: Seeing the months in the sidebar
        Given there is a post titled "Dr. No" published the "23 January 1963"
        And there is a post titled "From Russia With Love" published the "10 October 1963"
        And there is a post titled "Goldfinger" published the "17 September 1964"
        When I go to the homepage
        Then I should see "Archives" in the sidebar
        And I should see "January 1963" in the sidebar
        And I should see "October 1963" in the sidebar
        And I should see "September 1964" in the sidebar

    Scenario: Seeing all the posts from a month
        Given there is a post titled "Escalade" published the "12 December 2010"
        And there is a post titled "Christmas" published the "24 December 2010"
        And there is a post titled "New Year" published the "31 December 2010"
        And I am on the homepage
        When I follow "December 2010" in the sidebar
        Then I should be on the archives page for the month "December 2010"
        And I should see "December 2010" in the content
        And I should see the list of all the posts published on "December 2010"

    Scenario: Seeing the posts sorted and grouped by month
        Given there is one post per month in the year 2010
        Given I am on the homepage
        When I follow "Archives" in the sidebar
        Then I should be on the archives by month page
        And I should see "archives by month" in the content
        And I should see all the months from the year 2010
        And I should see all the posts published in 2010
