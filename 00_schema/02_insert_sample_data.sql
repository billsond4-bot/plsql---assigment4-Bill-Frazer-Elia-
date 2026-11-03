-- Sample data. Run after 01_create_tables.sql.
-- Note: students 1002 and 1005 share the same name on purpose (used for the TOO_MANY_ROWS test).
-- Note: MATH8101 has capacity 2 and two students, so it is already full (used for the "course full" test).
-- Note: student 1006 is SUSPENDED (used for the inactive-student test).

INSERT INTO students (student_id, full_name, email, department, status) VALUES (1001, 'Alice Uwase',       'alice.uwase@student.example.rw',    'Information Systems', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1002, 'Eric Mugisha',      'eric.mugisha1@student.example.rw',  'Information Systems', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1003, 'Grace Ingabire',    'grace.ingabire@student.example.rw', 'Software Engineering','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1004, 'David Niyonzima',   'david.niyonzima@student.example.rw','Software Engineering','ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1005, 'Eric Mugisha',      'eric.mugisha2@student.example.rw',  'Information Systems', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1006, 'Sandrine Mukamana','sandrine.m@student.example.rw',     'Information Systems', 'SUSPENDED');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1007, 'Patrick Habimana',  'patrick.h@student.example.rw',      'Information Systems', 'ACTIVE');
INSERT INTO students (student_id, full_name, email, department, status) VALUES (1008, 'Joyce Uwimana',     'joyce.uwimana@student.example.rw',  'Software Engineering','ACTIVE');

INSERT INTO courses (course_id, title, credits, capacity) VALUES ('INSY8311', 'Database Development with PL/SQL',   3, 30);
INSERT INTO courses (course_id, title, credits, capacity) VALUES ('INSY8313', 'Introduction to Big Data Analytics', 3, 30);
INSERT INTO courses (course_id, title, credits, capacity) VALUES ('SENG8215', 'Software Engineering',              3, 25);
INSERT INTO courses (course_id, title, credits, capacity) VALUES ('EPC82211', 'English Proficiency Certificate',   2, 40);
INSERT INTO courses (course_id, title, credits, capacity) VALUES ('MATH8101', 'Discrete Mathematics',              3, 2);

-- INSY8311
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1001, 'INSY8311', '2026-FALL', 92);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1002, 'INSY8311', '2026-FALL', 78);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1003, 'INSY8311', '2026-FALL', 85);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1004, 'INSY8311', '2026-FALL', 64);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1007, 'INSY8311', '2026-FALL', 98);  -- +5 bonus will break the 100 limit
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1008, 'INSY8311', '2026-FALL', 55);
-- INSY8313
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1001, 'INSY8313', '2026-FALL', 88);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1003, 'INSY8313', '2026-FALL', 71);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1004, 'INSY8313', '2026-FALL', NULL);  -- not graded yet
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1007, 'INSY8313', '2026-FALL', 66);
-- SENG8215
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1002, 'SENG8215', '2026-FALL', 59);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1005, 'SENG8215', '2026-FALL', 82);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1008, 'SENG8215', '2026-FALL', NULL);
-- EPC82211
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1001, 'EPC82211', '2026-FALL', 90);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1002, 'EPC82211', '2026-FALL', 74);
-- MATH8101 (capacity 2 -> full)
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1003, 'MATH8101', '2026-FALL', 80);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1004, 'MATH8101', '2026-FALL', 45);

COMMIT;
