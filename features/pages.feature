Feature: see the static pages
    In order to read about the blog and the author
    As a visitor
    I want to be able to browse the static pages

    Background:
        Given the blog is configured

    Scenario: Seeing the static pages list in the sidebar
        Given there is a page titled "for long you live and high you fly"
        And there is a page titled "and smiles you'll give and tears you'll cry"
        When I go to the homepage
        Then I should see "Pages" in the sidebar
        Then I should see "for long you live and high you fly" in the sidebar
        And I should see "and smiles you'll give and tears you'll cry" in the sidebar

    Scenario: clicking on a static page link from the sidebar
        Given there is a page titled "my title" with "shake ya body" as body
        And I am on the homepage
        When I follow "my title" in the sidebar
        Then I should be on the page "my title"
        And I should see "my title" in the content
        And I should see "shake ya body" in the content

    Scenario: seeing the static pages index
        Given I am on the homepage
        And there is a page titled "and all your touch and all you see"
        And there is a page titled "is all your life will ever be"
        When I follow "Pages" in the sidebar
        Then I should be on the pages page
        And I should see "pages" in the content
        And I should see "and all your touch and all you see" in the content
        And I should see "is all your life will ever be" in the content

    Scenario: clicking on a static page link from the index
        Given there is a page titled "my title" with "shake ya body" as body
        And I am on the pages page
        When I follow "my title" in the content
        Then I should be on the page "my title"
        And I should see "my title" in the content
        And I should see "shake ya body" in the content
