-- How many free seats a course still has in a given semester.
-- Uses SELECT INTO, so a missing course raises NO_DATA_FOUND, which we translate to a clear error.
CREATE OR REPLACE FUNCTION get_course_seats_left (
  p_course_id IN courses.course_id%TYPE,
  p_semester  IN enrollments.semester%TYPE
) RETURN NUMBER
AS
  v_capacity courses.capacity%TYPE;
  v_taken    NUMBER;
BEGIN
  SELECT capacity INTO v_capacity
  FROM   courses
  WHERE  course_id = p_course_id;

  SELECT COUNT(*) INTO v_taken
  FROM   enrollments
  WHERE  course_id = p_course_id
  AND    semester  = p_semester;

  RETURN v_capacity - v_taken;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20031, 'Course ' || p_course_id || ' does not exist.');
END get_course_seats_left;
/
