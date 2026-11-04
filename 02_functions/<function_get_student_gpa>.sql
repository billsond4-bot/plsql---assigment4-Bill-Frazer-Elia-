-- Credit-weighted GPA on a 4.0 scale (A=4, B=3, C=2, D=1, F=0).
-- Only graded enrollments count. If there is nothing to average we raise an error
-- instead of returning 0, because a 0 GPA would look like a real (failing) result.
CREATE OR REPLACE FUNCTION get_student_gpa (
  p_student_id IN students.student_id%TYPE
) RETURN NUMBER
AS
  v_status  students.status%TYPE;
  v_points  NUMBER := 0;
  v_credits NUMBER := 0;

  CURSOR c_graded IS
    SELECT c.credits, e.marks
    FROM   enrollments e
    JOIN   courses c ON c.course_id = e.course_id
    WHERE  e.student_id = p_student_id
    AND    e.marks IS NOT NULL;
BEGIN
  -- only here to prove the student exists (NO_DATA_FOUND if not)
  SELECT status INTO v_status FROM students WHERE student_id = p_student_id;

  FOR r IN c_graded LOOP
    v_points := v_points + r.credits *
                CASE convert_marks_to_grade(r.marks)
                  WHEN 'A' THEN 4
                  WHEN 'B' THEN 3
                  WHEN 'C' THEN 2
                  WHEN 'D' THEN 1
                  ELSE 0
                END;
    v_credits := v_credits + r.credits;
  END LOOP;

  IF v_credits = 0 THEN
    RAISE_APPLICATION_ERROR(-20081, 'Student ' || p_student_id || ' has no graded courses yet.');
  END IF;

  RETURN ROUND(v_points / v_credits, 2);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20080, 'Student ' || p_student_id || ' does not exist.');
  WHEN OTHERS THEN
    RAISE;   -- includes our own -20081, passed on unchanged
END get_student_gpa;
/
