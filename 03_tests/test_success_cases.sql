-- Success cases. Run AFTER schema, sample data, functions and procedures.
-- Run from the repo root so the relative paths work, or just paste block by block.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 160
SET PAGESIZE 50

PROMPT ===== TEST 1: register_student (implicit cursor on INSERT) =====
DECLARE
  v_msg VARCHAR2(200);
BEGIN
  register_student(1009, 'Claudine Uwera', 'claudine.uwera@student.example.rw', 'Information Systems', v_msg);
  DBMS_OUTPUT.PUT_LINE(v_msg);
END;
/

PROMPT ===== TEST 2: enroll_student =====
DECLARE
  v_enr_id enrollments.enrollment_id%TYPE;
BEGIN
  enroll_student(1009, 'SENG8215', '2026-FALL', v_enr_id);
  DBMS_OUTPUT.PUT_LINE('New enrollment id (OUT parameter): ' || v_enr_id);
END;
/

PROMPT ===== TEST 3: record_marks (records + audit trail) =====
DECLARE
  v_enr_id enrollments.enrollment_id%TYPE;
BEGIN
  SELECT enrollment_id INTO v_enr_id
  FROM   enrollments
  WHERE  student_id = 1009 AND course_id = 'SENG8215' AND semester = '2026-FALL';

  record_marks(v_enr_id, 77);
END;
/
SELECT audit_id, enrollment_id, old_marks, new_marks FROM grade_audit;

PROMPT ===== TEST 4: update_student_status (SQL%FOUND / SQL%ROWCOUNT) =====
DECLARE
  v_rows NUMBER;
BEGIN
  update_student_status(1004, 'graduated', v_rows);
  DBMS_OUTPUT.PUT_LINE('Rows updated (OUT): ' || v_rows);
END;
/

PROMPT ===== TEST 5: functions called from SQL =====
SELECT e.enrollment_id, e.marks, convert_marks_to_grade(e.marks) AS computed_grade
FROM   enrollments e
WHERE  e.course_id = 'INSY8311' AND e.semester = '2026-FALL'
ORDER  BY e.marks DESC;

SELECT get_course_seats_left('INSY8311', '2026-FALL') AS seats_left_insy8311 FROM dual;

PROMPT ===== TEST 6: functions called from an anonymous block =====
DECLARE
  v_id  students.student_id%TYPE;
  v_gpa NUMBER;
BEGIN
  v_id  := get_student_id_by_name('alice uwase');
  v_gpa := get_student_gpa(v_id);
  DBMS_OUTPUT.PUT_LINE('Alice Uwase has id ' || v_id || ' and GPA ' || v_gpa);
END;
/

PROMPT ===== TEST 7: print_course_roster (explicit cursor, OPEN/FETCH/CLOSE) =====
BEGIN
  print_course_roster('INSY8311', '2026-FALL');
END;
/

PROMPT ===== TEST 8: print_student_transcript (cursor FOR loop + associative array of records) =====
BEGIN
  print_student_transcript(1001);
  print_student_transcript(1006);   -- suspended student with no enrollments
END;
/

PROMPT ===== TEST 9: report_top_students (VARRAY) =====
BEGIN
  report_top_students('INSY8311', '2026-FALL');
END;
/

PROMPT ===== TEST 10: bulk_apply_bonus (BULK COLLECT + FORALL SAVE EXCEPTIONS) =====
-- Patrick has 98, so +5 breaks the 0-100 check. The other 2 rows should still be updated.
DECLARE
  v_ok   PLS_INTEGER;
  v_fail PLS_INTEGER;
BEGIN
  bulk_apply_bonus('INSY8311', '2026-FALL', 5, v_ok, v_fail);
  DBMS_OUTPUT.PUT_LINE('updated=' || v_ok || ', failed=' || v_fail);
END;
/
SELECT log_id, enrollment_id, error_code, SUBSTR(error_message, 1, 90) AS error_message FROM bulk_error_log;

PROMPT ===== TEST 11: bulk_assign_grade_letters (BULK COLLECT LIMIT + FORALL) =====
DECLARE
  v_total PLS_INTEGER;
BEGIN
  bulk_assign_grade_letters('2026-FALL', v_total);
END;
/
SELECT course_id, COUNT(*) AS enrollments, COUNT(grade_letter) AS with_grade
FROM   enrollments GROUP  BY course_id ORDER  BY course_id;

PROMPT ===== TEST 12: bulk_vs_row_demo (performance comparison) =====
BEGIN
  bulk_vs_row_demo(20000);
END;
/

PROMPT ===== TEST 13: drop_enrollment (implicit cursor on DELETE) =====
DECLARE
  v_enr_id enrollments.enrollment_id%TYPE;
  v_rows   NUMBER;
BEGIN
  SELECT enrollment_id INTO v_enr_id
  FROM   enrollments
  WHERE  student_id = 1009 AND course_id = 'SENG8215' AND semester = '2026-FALL';

  drop_enrollment(v_enr_id, v_rows);
END;
/
