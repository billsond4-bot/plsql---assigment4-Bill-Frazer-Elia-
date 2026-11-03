-- Prints everyone enrolled in a course. Parameterised explicit cursor,
-- handled with OPEN / FETCH / CLOSE and a cursor-based %ROWTYPE record.
CREATE OR REPLACE PROCEDURE print_course_roster (
  p_course_id IN courses.course_id%TYPE,
  p_semester  IN enrollments.semester%TYPE
)
AS
  CURSOR c_roster (cp_course courses.course_id%TYPE,
                   cp_semester enrollments.semester%TYPE) IS
    SELECT s.student_id, s.full_name, e.marks, e.grade_letter
    FROM   enrollments e
    JOIN   students s ON s.student_id = e.student_id
    WHERE  e.course_id = cp_course
    AND    e.semester  = cp_semester
    ORDER  BY s.full_name;

  v_row   c_roster%ROWTYPE;
  v_count PLS_INTEGER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Roster for ' || p_course_id || ' (' || p_semester || ')');
  DBMS_OUTPUT.PUT_LINE(RPAD('ID', 7) || RPAD('Name', 22) || RPAD('Marks', 8) || 'Grade');

  OPEN c_roster(p_course_id, p_semester);
  LOOP
    FETCH c_roster INTO v_row;
    EXIT WHEN c_roster%NOTFOUND;

    v_count := v_count + 1;
    DBMS_OUTPUT.PUT_LINE(RPAD(v_row.student_id, 7) ||
                         RPAD(v_row.full_name, 22) ||
                         RPAD(NVL(TO_CHAR(v_row.marks), '-'), 8) ||
                         NVL(v_row.grade_letter, '-'));
  END LOOP;
  CLOSE c_roster;

  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20050, 'Nobody is enrolled in ' || p_course_id ||
                                    ' for ' || p_semester || '.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('Total students: ' || v_count);
EXCEPTION
  WHEN OTHERS THEN
    IF c_roster%ISOPEN THEN
      CLOSE c_roster;
    END IF;
    RAISE;
END print_course_roster;
/
