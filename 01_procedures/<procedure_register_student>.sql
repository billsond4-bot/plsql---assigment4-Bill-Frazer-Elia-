-- Adds a new student. Implicit cursor on INSERT (SQL%ROWCOUNT).
CREATE OR REPLACE PROCEDURE register_student (
  p_student_id IN  students.student_id%TYPE,
  p_full_name  IN  students.full_name%TYPE,
  p_email      IN  students.email%TYPE,
  p_department IN  students.department%TYPE,
  p_message    OUT VARCHAR2
)
AS
  e_blank_name EXCEPTION;   -- user-defined exception
BEGIN
  IF TRIM(p_full_name) IS NULL THEN
    RAISE e_blank_name;
  END IF;

  INSERT INTO students (student_id, full_name, email, department)
  VALUES (p_student_id, TRIM(p_full_name), LOWER(p_email), p_department);

  IF SQL%ROWCOUNT = 1 THEN
    p_message := 'Student ' || p_student_id || ' (' || TRIM(p_full_name) || ') registered.';
  END IF;
EXCEPTION
  WHEN e_blank_name THEN
    RAISE_APPLICATION_ERROR(-20001, 'Full name cannot be blank.');
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20002, 'Student id ' || p_student_id ||
                                    ' or email ' || p_email || ' is already registered.');
  WHEN OTHERS THEN
    RAISE;
END register_student;
/
