# plsql---assigment4-Bill-Frazer-Elia-
My project is a student registration and grading system for a university. It stores students, courses and enrollments, and lets staff register students, enrol them in courses, record marks and produce reports.
# Student Registration and Grading System (Oracle PL/SQL)

**Course:** Database Development with PL/SQL (INSY 8311), AUCA
**Instructor:** Eric Maniraguha  |  **TA:** Afanyu Emmanuel
**Assignment:** Group Assignment IV: Records, Collections, Cursors, Bulk Processing, Procedures, Functions, Exceptions

## Group members

| Name | Student ID | Class group |
|------|-----------|-------------|
| (full name 1) | (ID 1) | (I / B / C / D) |
| (full name 2) | (ID 2) | (I / B / C / D) |

## What the application does

A small university system for registering students, enrolling them in courses and recording grades.
We picked it because every concept in the assignment has a natural place in it:

- a student is a row, so `%ROWTYPE` records fit well;
- a transcript is a list of courses, so a collection of records fits;
- giving bonus marks or grade letters to a whole class is a bulk job, which is where `BULK COLLECT` and `FORALL` make sense;
- registration has real rules (course full, student suspended, marks between 0 and 100), so exceptions are needed.

### Requirements we set for ourselves

1. Register a new student, and refuse duplicates or blank names.
2. Enrol an active student in a course, refusing full courses and double enrolment.
3. Record marks with an audit trail (old and new value).
4. Change student status and delete enrollments.
5. Print a course roster, a student transcript and the top 3 students of a course.
6. Give bonus marks to a whole class and assign grade letters in bulk, without one bad row cancelling the rest.
7. Calculate a letter grade, a GPA, free seats, and look up a student id by name.

### Tables

`students`, `courses`, `enrollments` (links students and courses, holds marks and grade),
`grade_audit` (history of mark changes), `bulk_error_log` (rows that failed in a bulk update),
`perf_demo` (scratch table for the performance comparison).
Relationships, keys and CHECK / UNIQUE constraints are in `00_schema/01_create_tables.sql`.

### Grading scale used

A >= 85, B >= 70, C >= 60, D >= 50, F below 50. GPA points: A=4, B=3, C=2, D=1, F=0, weighted by credits.

## Where each requirement is covered

| Requirement | Where |
|---|---|
| User-defined records | `record_marks`, `print_student_transcript` |
| `%ROWTYPE` records | `enroll_student`, `record_marks`, `print_student_transcript`, `print_course_roster` |
| Associative array | `print_student_transcript`, `bulk_assign_grade_letters`, `bulk_vs_row_demo` |
| Nested table | `bulk_apply_bonus`, `bulk_assign_grade_letters` |
| VARRAY | `report_top_students` |
| Implicit cursor (INSERT / UPDATE / DELETE, `SQL%ROWCOUNT`, `%FOUND`, `%NOTFOUND`) | `register_student`, `update_student_status`, `drop_enrollment` |
| Explicit cursor (OPEN / FETCH / CLOSE) | `print_course_roster`, `bulk_assign_grade_letters` |
| Cursor FOR loop | `print_student_transcript`, `get_student_gpa` |
| `BULK COLLECT` | `bulk_apply_bonus`, `bulk_assign_grade_letters` (with `LIMIT`), `report_top_students` |
| `FORALL` + `SAVE EXCEPTIONS` | `bulk_apply_bonus`, `bulk_assign_grade_letters`, `bulk_vs_row_demo` |
| Predefined exceptions | `NO_DATA_FOUND`, `TOO_MANY_ROWS`, `DUP_VAL_ON_INDEX` |
| User-defined exceptions / `RAISE_APPLICATION_ERROR` | all procedures and functions (codes -20001 to -20100) |

The full error-code list and the performance discussion are in `docs/IMPLEMENTATION_NOTES.md`.

## How to run

Quick way: start SQL*Plus in the repo folder and run `@run_all.sql`. It does every step below in order.
To run the steps one by one:

Requirements: Oracle Database 12c or newer (we used Oracle Database Free) and SQL*Plus, SQL Developer or the VS Code Oracle extension.
Connect as the same user for every step.

1. `@00_schema/01_create_tables.sql`
2. `@00_schema/02_insert_sample_data.sql`
3. Compile the functions: run every file in `02_functions/`.
   (We compile the functions before the procedures because several procedures call them.
   If you do it the other way round the procedures compile with errors and Oracle only fixes them on first use.)
4. Compile the procedures: run every file in `01_procedures/`.
5. `@03_tests/test_success_cases.sql`
6. To test errors on clean data, re-run steps 1 and 2, then `@03_tests/test_error_cases.sql`
7. Screenshots of each test go in `screenshots/`.

Procedures do not `COMMIT` by themselves. The caller decides, so a test can be rolled back.

## Use of AI

(I used AI to generate the data and I create the tables and insect  the vaiues that was generate and used it to work on the required processes.)



(Who did what: for example schema and sample data, procedures, functions, tests, documentation.)

