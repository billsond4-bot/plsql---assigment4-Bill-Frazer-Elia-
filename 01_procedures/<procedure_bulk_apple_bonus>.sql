-- Adds bonus marks to every graded student of a course.
-- BULK COLLECT reads the rows, FORALL ... SAVE EXCEPTIONS updates them.
-- If some rows fail (for example the result would be over 100 and break the check
-- constraint) the good rows are still updated and each failure is saved in bulk_error_log.
CREATE OR REPLACE PROCEDURE bulk_apply_bonus (
  p_course_id IN  enrollments.course_id%TYPE,
  p_semester  IN  enrollments.semester%TYPE,
  p_bonus     IN  NUMBER,
  p_updated   OUT PLS_INTEGER,
  p_failed    OUT PLS_INTEGER
)
AS
  TYPE t_ids   IS TABLE OF enrollments.enrollment_id%TYPE;
  TYPE t_marks IS TABLE OF enrollments.marks%TYPE;
  v_ids   t_ids;
  v_marks t_marks;

  v_err_count PLS_INTEGER;
  v_bad_index PLS_INTEGER;

  e_bulk_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);
BEGIN
  p_updated := 0;
  p_failed  := 0;

  IF p_bonus IS NULL OR p_bonus <= 0 THEN
    RAISE_APPLICATION_ERROR(-20070, 'Bonus must be a positive number.');
  END IF;

  SELECT enrollment_id, marks
  BULK COLLECT INTO v_ids, v_marks
  FROM   enrollments
  WHERE  course_id = p_course_id
  AND    semester  = p_semester
  AND    marks IS NOT NULL;

  IF v_ids.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20071, 'No graded enrollments for ' || p_course_id ||
                                    ' in ' || p_semester || '.');
  END IF;

  FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
    UPDATE enrollments
    SET    marks = v_marks(i) + p_bonus
    WHERE  enrollment_id = v_ids(i);

  p_updated := SQL%ROWCOUNT;
EXCEPTION
  WHEN e_bulk_errors THEN
    -- copy these first: later DML would overwrite SQL%ROWCOUNT
    p_updated   := SQL%ROWCOUNT;
    v_err_count := SQL%BULK_EXCEPTIONS.COUNT;
    p_failed    := v_err_count;

    FOR j IN 1 .. v_err_count LOOP
      v_bad_index := SQL%BULK_EXCEPTIONS(j).ERROR_INDEX;
      INSERT INTO bulk_error_log (enrollment_id, error_code, error_message)
      VALUES (v_ids(v_bad_index),
              SQL%BULK_EXCEPTIONS(j).ERROR_CODE,
              SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Bonus applied to ' || p_updated || ' rows, ' ||
                         p_failed || ' failed (see bulk_error_log).');
  WHEN OTHERS THEN
    RAISE;
END bulk_apply_bonus;
/
