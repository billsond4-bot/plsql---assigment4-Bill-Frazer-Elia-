SET SERVEROUTPUT ON;

BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('PERF_DEMO','BULK_ERROR_LOG','GRADE_AUDIT',
                                 'ENROLLMENTS','COURSES','STUDENTS')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/

CREATE TABLE students (
  student_id    NUMBER(8)     CONSTRAINT pk_students PRIMARY KEY,
  full_name     VARCHAR2(80)  NOT NULL,
  email         VARCHAR2(100) NOT NULL CONSTRAINT uq_students_email UNIQUE,
  department    VARCHAR2(40)  NOT NULL,
  status        VARCHAR2(10)  DEFAULT 'ACTIVE' NOT NULL
                CONSTRAINT ck_students_status
                CHECK (status IN ('ACTIVE','SUSPENDED','GRADUATED')),
  registered_on DATE          DEFAULT SYSDATE NOT NULL
);

CREATE TABLE courses (
  course_id VARCHAR2(10)  CONSTRAINT pk_courses PRIMARY KEY,
  title     VARCHAR2(80)  NOT NULL,
  credits   NUMBER(1)     NOT NULL CONSTRAINT ck_courses_credits CHECK (credits BETWEEN 1 AND 6),
  capacity  NUMBER(3)     NOT NULL CONSTRAINT ck_courses_capacity CHECK (capacity > 0)
);

CREATE TABLE enrollments (
  enrollment_id NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_enrollments PRIMARY KEY,
  student_id    NUMBER(8)    NOT NULL CONSTRAINT fk_enr_student REFERENCES students(student_id),
  course_id     VARCHAR2(10) NOT NULL CONSTRAINT fk_enr_course  REFERENCES courses(course_id),
  semester      VARCHAR2(10) NOT NULL,
  marks         NUMBER(5,2)  CONSTRAINT ck_enr_marks CHECK (marks BETWEEN 0 AND 100),
  grade_letter  VARCHAR2(2),
  enrolled_on   DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT uq_enr_student_course_sem UNIQUE (student_id, course_id, semester)
);

CREATE INDEX idx_enr_course_sem ON enrollments (course_id, semester);

-- No foreign key on purpose: audit history must survive even if an enrollment is dropped.
CREATE TABLE grade_audit (
  audit_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  enrollment_id NUMBER NOT NULL,
  old_marks     NUMBER(5,2),
  new_marks     NUMBER(5,2),
  changed_by    VARCHAR2(30) DEFAULT USER,
  changed_on    TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE bulk_error_log (
  log_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  enrollment_id NUMBER,
  error_code    NUMBER,
  error_message VARCHAR2(4000),
  logged_on     TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- Scratch table used only by bulk_vs_row_demo
CREATE TABLE perf_demo (
  id    NUMBER,
  label VARCHAR2(30)
);

