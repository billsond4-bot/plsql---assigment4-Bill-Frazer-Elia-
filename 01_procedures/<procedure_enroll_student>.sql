-- Enrols a student in a course for a semester.
-- Uses a %ROWTYPE record for the student, a function to check seats,
-- and returns the new enrollment id through an OUT parameter.
CREATE OR REPLACE PROCEDURE enroll_student (
  p_student_id    IN  students.student_id%TYPE,
  p_course_id     IN  courses.course_id%TYPE,
  p_semester      IN  enrollments.semester%TYPE,
  p_enrollment_id OUT enrollments.enrollment_id%TYPE
)
AS
  v_student students%ROWTYPE;
  v_seats   NUMBER;

  e_student_inactive EXCEPTION;
  e_course_full      EXCEPTION;
BEGIN
  SELECT * INTO v_student
  FROM   students
  WHERE  student_id = p_student_id;

  IF v_student.status <> 'ACTIVE' THEN
    RAISE e_student_inactive;
  END IF;

  v_seats := get_course_seats_left(p_course_id, p_semester);
  IF v_seats <= 0 THEN
    RAISE e_course_full;
  END IF;

  INSERT INTO enrollments (student_id, course_id, semester)
  VALUES (p_student_id, p_course_id, p_semester)
  RETURNING enrollment_id INTO p_enrollment_id;

  DBMS_OUTPUT.PUT_LINE(v_student.full_name || ' enrolled in ' || p_course_id ||
                       ' (' || p_semester || '), enrollment id ' || p_enrollment_id || '.');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20010, 'Student ' || p_student_id || ' does not exist.');
  WHEN e_student_inactive THEN
    RAISE_APPLICATION_ERROR(-20011, 'Student ' || p_student_id ||
                                    ' is ' || v_student.status || ' and cannot enrol.');
  WHEN e_course_full THEN
    RAISE_APPLICATION_ERROR(-20012, 'Course ' || p_course_id || ' is full for ' || p_semester || '.');
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20013, 'Student ' || p_student_id || ' is already enrolled in ' ||
                                    p_course_id || ' for ' || p_semester || '.');
  WHEN OTHERS THEN
    RAISE;
END enroll_student;
/
