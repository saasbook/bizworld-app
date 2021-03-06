Feature: add students to a class

	As a teacher
	I want to be able to add students to my class
	So that I can track each student's progress and administer pre/post tests

Background: Teacher exists and has a class

  Given the following teacher is signed up:
  | name         | school_name  | city         | state | email				        | username	| password |
  | Armando Fox  | UC Berkeley  | Berkeley     | CA    | armando@berkeley.edu | Armando 	| password |

  And the following classrooms belong to the teacher:
  | name       | program     | class_type   | start_date | end_date	 |
  | Monday 8AM | Bizworld    | After School | 1-1-2015   | 1-10-2015 |

  And the teacher is signed in

Scenario: add students to class via form
  Given I am "Armando Fox" looking at "Monday 8AM"
  And I press "Add students to class"
  And I add the following students via form:
  | name           |
  | Tom Brady      |
  | Peyton Manning |
  | Drew Brees     |

  Then I should see "Tom Brady"
  And I should see "Peyton Manning"
  And I should see "Drew Brees"

Scenario: add improperly formatted students to class via form
  Given I am "Armando Fox" looking at "Monday 8AM"
  And I press "Add students to class"
  And I add the following students via form:
  | name           |
  | Tom Brady      |
  | Peyton Manning |
  | Abigail        |
  | Drew Brees     |
  | Elias          |

  And I follow "Classrooms"
  And I follow "Monday 8AM"
  Then I should see "Tom Brady"
  And I should see "Peyton Manning"
  And I should see "Drew Brees"
  And I should not see "Abigail"
  And I should not see "Elias"

Scenario: add students to class via spreadsheet
  Given I am "Armando Fox" looking at "Monday 8AM"
  And I press "Add students to class"
  And I import the student names spreadsheet student_names.xlsx

  Then I should see "Jerry Seinfeld"
  And I should see "Larry David"
  And I should see "Louis CK"

Scenario: upload spreadsheet with improper labels
  Given I am "Armando Fox" looking at "Monday 8AM"
  And I press "Add students to class"
  And I import the student names spreadsheet improper_labels.xlsx

  Then I should not see "Nasir Jones"
  And I should not see "Shawn Carter"
  And I should see "Unable to add students"

Scenario: Should propmt user to upload proper file type if they upload an improper file type
  Given I am "Armando Fox" looking at "Monday 8AM"
  And I press "Add students to class"
  And I import the improper file pear.jpeg
  Then I should see "Unknown file type; please upload an .xls or .xlsx file."

Scenario: Should prompt user to upload a file if no file uploaded
  Given I am "Armando Fox" looking at "Monday 8AM"
  And I press "Add students to class"
  And I press "Import"
  Then I should see "Please upload a file"
