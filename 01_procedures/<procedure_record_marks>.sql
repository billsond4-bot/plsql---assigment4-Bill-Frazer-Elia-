-- Saves marks for one enrollment and writes an audit row.
-- A user-defined record keeps the "before and after" values together,
-- and a %ROWTYPE record holds the row we lock with FOR UPDATE.
CREATE OR REPLACE PROCEDURE record_marks (
  p_enrollment_id IN enrollments.enrollment_id%TYPE,
  p_new_marks     IN enrollments.marks%TYPE
)
AS
  TYPE t_mark_change IS RECORD (
    enrollment_id enrollments.enrollment_id%TYPE,
    old_marks     enrollments.marks%TYPE,
    new_marks     enrollments.marks%TYPE,
    new_grade     enrollments.grade_letter%TYPE
  );
  v_change     t_mark_change;
  v_enrollment enrollments%ROWTYPE;
BEGIN
  IF p_new_marks IS NULL OR p_new_marks < 0 OR p_new_marks > 100 THEN
    RAISE_APPLICATION_ERROR(-20040, 'Marks must be a number between 0 and 100.');
  END IF;

  SELECT * INTO v_enrollment
  FROM   enrollments
  WHERE  enrollment_id = p_enrollment_id
  FOR UPDATE;

  v_change.enrollment_id := v_enrollment.enrollment_id;
  v_change.old_marks     := v_enrollment.marks;
  v_change.new_marks     := p_new_marks;
  v_change.new_grade     := convert_marks_to_grade(p_new_marks);

  UPDATE enrollments
  SET    marks        = v_change.new_marks,
         grade_letter = v_change.new_grade
  WHERE  enrollment_id = v_change.enrollment_id;

  INSERT INTO grade_audit (enrollment_id, old_marks, new_marks)
  VALUES (v_change.enrollment_id, v_change.old_marks, v_change.new_marks);

  DBMS_OUTPUT.PUT_LINE('Enrollment ' || v_change.enrollment_id || ': marks ' ||
                       NVL(TO_CHAR(v_change.old_marks), 'none') || ' -> ' ||
                       v_change.new_marks || ' (grade ' || v_change.new_grade || ').');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20041, 'Enrollment ' || p_enrollment_id || ' does not exist.');
  WHEN OTHERS THEN
    RAISE;
END record_marks;
/
