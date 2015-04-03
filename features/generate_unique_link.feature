Feature: create a unique pre/post test link

  As a teacher
  I want to be able to administer class-unique pre/post tests
  So that I can give students a pre-populated survey to test their knowledge and progress

Background: one teacher and two classes have been added to the database

  Given the following teacher is signed up:
  | name         | school_name  | city         | state | email                | username  | password |
  | Armando Fox  | UC Berkeley  | Berkeley     | CA    | armando@berkeley.edu | Armando   | password |

  And the following classrooms exists:
  | name      | grade       | teacher       |
  | class a   | 3           | Armando Fox   |
  | class b   | 4           | Armando Fox   |

  And the teacher is signed in

Scenario: generate link for "class a"
  Given I am "Armando Fox" looking at "class a"
  And I want to administer a pre-test 
  Then I should see the link to pre-test
