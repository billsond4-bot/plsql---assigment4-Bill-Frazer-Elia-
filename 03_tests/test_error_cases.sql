-- Error cases. Run after the schema and sample data (re-run 00_schema first for clean data).
-- Every test below is EXPECTED to fail. expect_error runs a PL/SQL block, catches the error
-- and prints it, so the script keeps going. If a test does NOT fail, it says so.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 160

DECLARE
  PROCEDURE expect_error (p_label IN VARCHAR2, p_block IN VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE p_block;
    DBMS_OUTPUT.PUT_LINE(p_label || ' -> NO ERROR (unexpected)');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(p_label || ' -> ' || SQLERRM);
  END expect_error;
BEGIN
  -- register_student
  expect_error('E1  blank name           ', q'[DECLARE m VARCHAR2(200); BEGIN register_student(2001, '  ', 'x@s.rw', 'IS', m); END;]');
  expect_error('E2  duplicate student id ', q'[DECLARE m VARCHAR2(200); BEGIN register_student(1001, 'Other', 'o@s.rw', 'IS', m); END;]');

  -- enroll_student
  expect_error('E3  student not found    ', q'[DECLARE i NUMBER; BEGIN enroll_student(9999, 'INSY8311', '2026-FALL', i); END;]');
  expect_error('E4  student suspended    ', q'[DECLARE i NUMBER; BEGIN enroll_student(1006, 'INSY8311', '2026-FALL', i); END;]');
  expect_error('E5  course full          ', q'[DECLARE i NUMBER; BEGIN enroll_student(1001, 'INSY8313', '2026-FALL', i); END;]');
  expect_error('E6  already enrolled     ', q'[DECLARE i NUMBER; BEGIN enroll_student(1001, 'INSY8311', '2026-FALL', i); END;]');
  expect_error('E7  course not found     ', q'[DECLARE i NUMBER; BEGIN enroll_student(1001, 'NOPE0000', '2026-FALL', i); END;]');

  -- update_student_status / drop_enrollment
  expect_error('E8  invalid status       ', q'[DECLARE r NUMBER; BEGIN update_student_status(1001, 'RETIRED', r); END;]');
  expect_error('E9  update missing student', q'[DECLARE r NUMBER; BEGIN update_student_status(9999, 'ACTIVE', r); END;]');
  expect_error('E10 drop missing enrolment', q'[DECLARE r NUMBER; BEGIN drop_enrollment(999999, r); END;]');

  -- record_marks
  expect_error('E11 marks out of range   ', q'[BEGIN record_marks(1, 150); END;]');
  expect_error('E12 enrolment not found  ', q'[BEGIN record_marks(999999, 60); END;]');

  -- functions
  expect_error('E13 GPA, no graded course', q'[DECLARE g NUMBER; BEGIN g := get_student_gpa(1006); END;]');
  expect_error('E14 GPA, unknown student ', q'[DECLARE g NUMBER; BEGIN g := get_student_gpa(9999); END;]');
  expect_error('E15 name matches 2 rows  ', q'[DECLARE i NUMBER; BEGIN i := get_student_id_by_name('Eric Mugisha'); END;]');
  expect_error('E16 name not found       ', q'[DECLARE i NUMBER; BEGIN i := get_student_id_by_name('Nobody Here'); END;]');
  expect_error('E17 grade of NULL marks  ', q'[DECLARE g VARCHAR2(2); BEGIN g := convert_marks_to_grade(NULL); END;]');
  expect_error('E18 grade of 130 marks   ', q'[DECLARE g VARCHAR2(2); BEGIN g := convert_marks_to_grade(130); END;]');

  -- reports and bulk procedures
  expect_error('E19 empty roster         ', q'[BEGIN print_course_roster('EPC82211', '2020-FALL'); END;]');
  expect_error('E20 transcript, no student', q'[BEGIN print_student_transcript(9999); END;]');
  expect_error('E21 negative bonus       ', q'[DECLARE a PLS_INTEGER; b PLS_INTEGER; BEGIN bulk_apply_bonus('INSY8311', '2026-FALL', -3, a, b); END;]');
  expect_error('E22 bonus, no rows       ', q'[DECLARE a PLS_INTEGER; b PLS_INTEGER; BEGIN bulk_apply_bonus('INSY8311', '1999-FALL', 5, a, b); END;]');
  expect_error('E23 bad row count        ', q'[BEGIN bulk_vs_row_demo(0); END;]');
END;
/

PROMPT ===== E24: bulk DML errors (ORA-24381 handled with SAVE EXCEPTIONS) =====
-- Patrick (98 + 5 = 103) breaks the 100 limit. The other rows are still updated.
DECLARE
  v_ok PLS_INTEGER; v_fail PLS_INTEGER;
BEGIN
  bulk_apply_bonus('INSY8311', '2026-FALL', 5, v_ok, v_fail);
  DBMS_OUTPUT.PUT_LINE('updated=' || v_ok || ', failed=' || v_fail);
END;
/
SELECT enrollment_id, error_code, SUBSTR(error_message, 1, 90) AS error_message FROM bulk_error_log;

ROLLBACK;
