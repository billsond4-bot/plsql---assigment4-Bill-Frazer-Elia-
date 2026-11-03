-- Changes a student's status. Implicit cursor on UPDATE:
-- SQL%ROWCOUNT, SQL%FOUND and SQL%NOTFOUND are all used.
CREATE OR REPLACE PROCEDURE update_student_status (
  p_student_id IN  students.student_id%TYPE,
  p_new_status IN  students.status%TYPE,
  p_rows       OUT NUMBER
)
AS
  e_bad_status EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bad_status, -2290);   -- check constraint violated
BEGIN
  UPDATE students
  SET    status = UPPER(TRIM(p_new_status))
  WHERE  student_id = p_student_id;

  p_rows := SQL%ROWCOUNT;

  IF SQL%NOTFOUND THEN
    RAISE_APPLICATION_ERROR(-20020, 'Student ' || p_student_id || ' does not exist.');
  ELSIF SQL%FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Student ' || p_student_id || ' is now ' || UPPER(TRIM(p_new_status)) ||
                         ' (' || p_rows || ' row updated).');
  END IF;
EXCEPTION
  WHEN e_bad_status THEN
    RAISE_APPLICATION_ERROR(-20021, '"' || p_new_status ||
                                    '" is not a valid status. Use ACTIVE, SUSPENDED or GRADUATED.');
  WHEN OTHERS THEN
    RAISE;
END update_student_status;
/
