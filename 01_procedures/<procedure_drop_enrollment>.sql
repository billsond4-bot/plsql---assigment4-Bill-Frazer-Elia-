-- Removes one enrollment. Implicit cursor on DELETE.
CREATE OR REPLACE PROCEDURE drop_enrollment (
  p_enrollment_id IN  enrollments.enrollment_id%TYPE,
  p_rows          OUT NUMBER
)
AS
BEGIN
  DELETE FROM enrollments
  WHERE  enrollment_id = p_enrollment_id;

  p_rows := SQL%ROWCOUNT;

  IF NOT SQL%FOUND THEN
    RAISE_APPLICATION_ERROR(-20030, 'Enrollment ' || p_enrollment_id || ' does not exist.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('Enrollment ' || p_enrollment_id || ' dropped (' || p_rows || ' row deleted).');
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END drop_enrollment;
/
