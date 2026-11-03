-- Shows the top 3 students in a course using a VARRAY (fixed maximum size of 3).
-- BULK COLLECT fills the VARRAY in one go.
CREATE OR REPLACE PROCEDURE report_top_students (
  p_course_id IN courses.course_id%TYPE,
  p_semester  IN enrollments.semester%TYPE
)
AS
  TYPE t_top3 IS VARRAY(3) OF VARCHAR2(120);
  v_top t_top3;
BEGIN
  SELECT s.full_name || ' - ' || e.marks
  BULK COLLECT INTO v_top
  FROM   enrollments e
  JOIN   students s ON s.student_id = e.student_id
  WHERE  e.course_id = p_course_id
  AND    e.semester  = p_semester
  AND    e.marks IS NOT NULL
  ORDER  BY e.marks DESC
  FETCH FIRST 3 ROWS ONLY;

  IF v_top.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20052, 'No graded students in ' || p_course_id ||
                                    ' for ' || p_semester || '.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('Top students in ' || p_course_id || ' (' || p_semester || '):');
  FOR i IN 1 .. v_top.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('  ' || i || '. ' || v_top(i));
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END report_top_students;
/
