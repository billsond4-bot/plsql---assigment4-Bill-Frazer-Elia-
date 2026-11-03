-- Fills grade_letter for every graded enrollment of a semester.
-- Reads in batches of 50 with BULK COLLECT ... LIMIT (keeps memory small on big tables),
-- then writes each batch back with FORALL.
CREATE OR REPLACE PROCEDURE bulk_assign_grade_letters (
  p_semester      IN  enrollments.semester%TYPE,
  p_total_updated OUT PLS_INTEGER
)
AS
  CURSOR c_marks IS
    SELECT enrollment_id, marks
    FROM   enrollments
    WHERE  semester = p_semester
    AND    marks IS NOT NULL;

  TYPE t_ids    IS TABLE OF enrollments.enrollment_id%TYPE;
  TYPE t_marks  IS TABLE OF enrollments.marks%TYPE;
  TYPE t_grades IS TABLE OF enrollments.grade_letter%TYPE INDEX BY PLS_INTEGER;

  v_ids    t_ids;
  v_marks  t_marks;
  v_grades t_grades;

  c_batch_size CONSTANT PLS_INTEGER := 50;
BEGIN
  p_total_updated := 0;

  OPEN c_marks;
  LOOP
    FETCH c_marks BULK COLLECT INTO v_ids, v_marks LIMIT c_batch_size;
    EXIT WHEN v_ids.COUNT = 0;       -- check COUNT, not %NOTFOUND, with LIMIT

    v_grades.DELETE;
    FOR i IN 1 .. v_ids.COUNT LOOP
      v_grades(i) := convert_marks_to_grade(v_marks(i));
    END LOOP;

    FORALL i IN 1 .. v_ids.COUNT
      UPDATE enrollments
      SET    grade_letter = v_grades(i)
      WHERE  enrollment_id = v_ids(i);

    p_total_updated := p_total_updated + SQL%ROWCOUNT;
  END LOOP;
  CLOSE c_marks;

  DBMS_OUTPUT.PUT_LINE('Grade letters set for ' || p_total_updated || ' enrollments in ' || p_semester || '.');
EXCEPTION
  WHEN OTHERS THEN
    IF c_marks%ISOPEN THEN
      CLOSE c_marks;
    END IF;
    RAISE;
END bulk_assign_grade_letters;
/
