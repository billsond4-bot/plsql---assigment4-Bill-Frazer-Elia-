-- Finds a student id from a full name (case-insensitive).
-- Shows both predefined exceptions: NO_DATA_FOUND and TOO_MANY_ROWS.
CREATE OR REPLACE FUNCTION get_student_id_by_name (
  p_full_name IN students.full_name%TYPE
) RETURN students.student_id%TYPE
AS
  v_id students.student_id%TYPE;
BEGIN
  SELECT student_id
  INTO   v_id
  FROM   students
  WHERE  UPPER(full_name) = UPPER(TRIM(p_full_name));

  RETURN v_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20090, 'No student named "' || p_full_name || '".');
  WHEN TOO_MANY_ROWS THEN
    RAISE_APPLICATION_ERROR(-20091, 'More than one student is named "' || p_full_name ||
                                    '". Search by student id instead.');
END get_student_id_by_name;
/
