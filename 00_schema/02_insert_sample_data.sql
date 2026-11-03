--   1002 and 1005 share a name            -> TOO_MANY_ROWS test
--   1006 is SUSPENDED and has no marks    -> inactive student + "no graded courses" tests
--   INSY8313 has capacity 1 and 1 student -> "course full" test
--   1007 has 98 marks                     -> a +5 bonus breaks the 100 limit (bulk error test)
--   1004 has NULL marks                   -> not graded yet

INSERT INTO students (student_id, full_name, email, department, status) VALUES (1001, 'Alice Uwase',       'alice.uwase@student.example.rw',   'Information Systems', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1002, 'Eric Mugisha',      'eric.mugisha1@student.example.rw', 'Information Systems', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1004, 'David Niyonzima',   'david.niyonzima@student.example.rw','Software Engineering','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1005, 'Eric Mugisha',      'eric.mugisha2@student.example.rw', 'Information Systems', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1006, 'Sandrine Mukamana','sandrine.m@student.example.rw',    'Information Systems', 'SUSPENDED');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1007, 'Patrick Habimana',  'patrick.h@student.example.rw',     'Information Systems', 'ACTIVE');

INSERT INTO courses (course_id, title, credits, capacity) VALUES ('INSY8311', 'Database Development with PL/SQL',   3, 30);
INSERT INTO courses (course_id, title, credits, capacity) VALUES ('INSY8313', 'Introduction to Big Data Analytics', 3, 1);
INSERT INTO courses (course_id, title, credits, capacity) VALUES ('SENG8215', 'Software Engineering',              3, 25);
INSERT INTO courses (course_id, title, credits, capacity) VALUES ('EPC82211', 'English Proficiency Certificate',   2, 40);

-- Enrollment marks (5 rows)
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1001, 'INSY8311', '2026-FALL', 92);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1007, 'INSY8311', '2026-FALL', 98);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1002, 'INSY8311', '2026-FALL', 78);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1001, 'EPC82211', '2026-FALL', 90);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1004, 'INSY8313', '2026-FALL', NULL);

COMMIT;

