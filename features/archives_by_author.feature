Feature: browse the archives by author
    In order to only see posts of interesting author
    As a visitor
    I want to browse the posts by author

    Background:
        Given the blog is configured

    Scenario: Seeing the authors in the sidebar
        Given there is an author named "Alan Turing"
        And there is an author named "C.A.R. Hoare"
        When I go to the homepage
        Then I should see "Authors" in the sidebar
        Then I should see "Alan Turing" in the sidebar
        And I should see "C.A.R. Hoare" in the sidebar

    Scenario: Seeing all the posts written by an author
        Given there is an author named "Niklaus Wirth" who wrote 3 posts
        And I am on the homepage
        When I follow "Niklaus Wirth" in the sidebar
        Then I should be on the archives page of the author "Niklaus Wirth"
        And I should see "Niklaus Wirth" in the content
        And I should see the posts list from the author "Niklaus Wirth"

    Scenario: Seeing all the posts grouped by author
        Given there is an author named "Grace Hopper" who wrote 1 posts
        And there is an author named "Ada Lovelace" who wrote 3 posts
        And I am on the homepage
        When I follow "Authors" in the sidebar
        Then I should be on the archives by author page
        And I should see "Grace Hopper" in the content
        And I should see the posts list from the author "Grace Hopper"
        And I should see "Ada Lovelace" in the content
        And I should see the posts list from the author "Ada Lovelace"

    Scenario: reading a post from the archive by author link
        Given there is an author named "Grace Hopper"
        And there is a post titled "COBOL is dead" by "Grace Hopper"
        And I am on the archives page of the author "Grace Hopper"
        When I follow "COBOL is dead" in the content
        Then I should be on the post page "COBOL is dead"
