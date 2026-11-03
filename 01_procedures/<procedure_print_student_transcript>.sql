-- Prints a student's transcript.
-- Cursor FOR loop fills an associative array (indexed by "semester/course")
-- whose elements are user-defined records. Then we walk the array with FIRST/NEXT.
CREATE OR REPLACE PROCEDURE print_student_transcript (
  p_student_id IN students.student_id%TYPE
)
AS
  v_student students%ROWTYPE;

  TYPE t_line IS RECORD (
    title   courses.title%TYPE,
    credits courses.credits%TYPE,
    marks   enrollments.marks%TYPE,
    grade   enrollments.grade_letter%TYPE
  );
  TYPE t_transcript IS TABLE OF t_line INDEX BY VARCHAR2(30);
  v_lines t_transcript;
  v_key   VARCHAR2(30);
  v_gpa   NUMBER;

  e_no_graded EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_no_graded, -20081);
BEGIN
  SELECT * INTO v_student
  FROM   students
  WHERE  student_id = p_student_id;

  FOR r IN (SELECT e.course_id, e.semester, c.title, c.credits, e.marks, e.grade_letter
            FROM   enrollments e
            JOIN   courses c ON c.course_id = e.course_id
            WHERE  e.student_id = p_student_id)
  LOOP
    v_key := r.semester || '/' || r.course_id;
    v_lines(v_key).title   := r.title;
    v_lines(v_key).credits := r.credits;
    v_lines(v_key).marks   := r.marks;
    v_lines(v_key).grade   := r.grade_letter;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Transcript: ' || v_student.full_name ||
                       ' (' || v_student.student_id || ', ' || v_student.status || ')');

  IF v_lines.COUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('  No enrollments yet.');
  ELSE
    v_key := v_lines.FIRST;
    WHILE v_key IS NOT NULL LOOP
      DBMS_OUTPUT.PUT_LINE('  ' || RPAD(v_key, 20) ||
                           RPAD(v_lines(v_key).title, 38) ||
                           RPAD(v_lines(v_key).credits || ' cr', 6) ||
                           RPAD(NVL(TO_CHAR(v_lines(v_key).marks), '-'), 7) ||
                           NVL(v_lines(v_key).grade, '-'));
      v_key := v_lines.NEXT(v_key);
    END LOOP;
  END IF;

  BEGIN
    v_gpa := get_student_gpa(p_student_id);
    DBMS_OUTPUT.PUT_LINE('  GPA: ' || v_gpa);
  EXCEPTION
    WHEN e_no_graded THEN
      DBMS_OUTPUT.PUT_LINE('  GPA: not available (no graded courses yet)');
  END;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20051, 'Student ' || p_student_id || ' does not exist.');
  WHEN OTHERS THEN
    RAISE;
END print_student_transcript;
/
