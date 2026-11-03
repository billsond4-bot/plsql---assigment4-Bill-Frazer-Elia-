-- Turns a mark (0-100) into a letter grade.
-- Scale used: A >= 85, B >= 70, C >= 60, D >= 50, otherwise F.
-- Bad input raises an error instead of returning a fake grade.
CREATE OR REPLACE FUNCTION convert_marks_to_grade (
  p_marks IN NUMBER
) RETURN VARCHAR2 DETERMINISTIC
AS
BEGIN
  IF p_marks IS NULL THEN
    RAISE_APPLICATION_ERROR(-20060, 'Cannot convert NULL marks to a grade.');
  END IF;

  IF p_marks < 0 OR p_marks > 100 THEN
    RAISE_APPLICATION_ERROR(-20061, 'Marks must be between 0 and 100, got ' || p_marks || '.');
  END IF;

  RETURN CASE
           WHEN p_marks >= 85 THEN 'A'
           WHEN p_marks >= 70 THEN 'B'
           WHEN p_marks >= 60 THEN 'C'
           WHEN p_marks >= 50 THEN 'D'
           ELSE 'F'
         END;
END convert_marks_to_grade;
/
