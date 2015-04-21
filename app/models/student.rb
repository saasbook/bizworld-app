class Student < ActiveRecord::Base
  has_many :classroom_students
  has_many :classrooms, :through => :classroom_students
  has_many :surveys
  attr_accessible :age, :ethnicity, :gender, :first_name, :last_name, :school_name, :teacher_name, :state, :grade, :city_name
  validates_presence_of :first_name, :last_name 


  def name
    "#{self.first_name} #{self.last_name}"
  end

  def get_survey(survey_type)
    self.surveys.each do |survey|
      if survey.survey_type == survey_type
        return survey
      end
    end
    nil
  end

  def get_survey_score(survey_type)
    survey = get_survey(survey_type)
    if survey
      survey.score
    else
      "N/A"
    end
  end

  def self.first_name_labels
    ["first_name", "first name", "first"]
  end

  def self.last_name_labels
    ["last_name", "last name", "last"]
  end

  def self.full_name_labels
    ["name", "full_name", "full name"]
  end

  def self.is_valid_name(first_name, last_name)
    return (first_name and last_name)
  end

  def self.parse_full_name(curr_first_name, curr_last_name, attrs)
    first_name = curr_first_name
    last_name = curr_last_name
    for key in attrs.keys()
      if Student.full_name_labels.include?(key.to_s.downcase)
        first_and_last = attrs[key].split(" ")
        first_name = first_and_last[0]
        last_name = first_and_last[1]
      end
    end
    return first_name, last_name
  end

  def self.parse_first_and_last_name_separately(curr_first_name, curr_last_name, attrs)
    for key in attrs.keys()
      if Student.first_name_labels.include?(key.to_s.downcase)
        first_name = attrs[key]
      end
    end
    for key in attrs.keys()
      if Student.last_name_labels.include?(key.to_s.downcase)
        last_name = attrs[key]
      end
    end
    return first_name, last_name
  end

  def self.import(file, classroom_id)
    error = ""
    spreadsheet = open_spreadsheet(file)
    if spreadsheet == "Unknown file type; please upload an .xls or .xlsx file."
      return spreadsheet
    end
    header = spreadsheet.row(1)
    classroom = Classroom.find(classroom_id)
    students_added = false
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      attrs = row.to_hash
      first_name = nil
      last_name = nil
      first_name, last_name = Student.parse_first_and_last_name_separately(first_name, last_name, attrs)
      if not Student.is_valid_name(first_name, last_name)
        first_name, last_name = Student.parse_full_name(first_name, last_name, attrs)
      end
      if Student.is_valid_name(first_name, last_name)
        classroom.students.create(:first_name => first_name, :last_name => last_name)
        students_added = true
      else
        error = "One or more students could not be read from the file."
      end
    end
    if not students_added
       error = "Unable to add students. Make sure the column headers are labeled
       as 'name', 'full name', or 'full_name' for full names; 'first', 'first name', or 'first_name'
       for first names; and 'last', 'last name', or 'last_name' for last names."
    end
    return error
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::Csv.new(file.path, nil, :ignore)
    when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
    when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
    else return "Unknown file type; please upload an .xls or .xlsx file."
    end
  end

  def self.master_student
    student = Student.find_by_first_name 'MASTER'
    if student.nil?
      student = Student.create(:first_name => 'MASTER',
                                :last_name => 'MASTER')
      key_dictionary = {"1. How can a company know it made a profit?" => "It earned more money in revenue than it spent on expenses",
                        "2. If you take out a loan from the bank, you must:" => "Repay the balance of the loan and interest",
                        "3. Your company made 10 of the same bracelet. Your total expenses, including bracelet materials, were $80. To make a profit how much should each bracelet cost?" => "$9",
                        "4. What does a venture capitalist receive in exchange for investing in a company?" => "Shares of stock in the company and a vote in decision-making.",
                        "5. Why is it important to keep careful records of all your finances?" => "All of the above.",
                        "6. If a company sells shares of stock, the company is:" => "Losing a part of the ownership of the company in exchange for money.",
                        "7. What is the profit equation?" => "Revenue - Expenses = Profit (or Loss)",
                        "8. Money a company earns from selling a product or service is called:" => "Revenue.",
                        "9. The most important goal of marketing is to:" => "All of the above.",
                        "10. When developing a product, during the manufacturing stage the company needs to:" => "Make the product quickly and with limited waste.",
                        "11. When deciding on a price for a product, what factor(s) should a company consider?" => "All of the above."
                        }
      key = student.surveys.create(version: Survey.current_version, survey_type: 'pre')
      key.populate(key_dictionary)
    end
    return student
  end

  def self.master_key(version)
    return self.master_student.surveys.find_by_version version
  end
end
