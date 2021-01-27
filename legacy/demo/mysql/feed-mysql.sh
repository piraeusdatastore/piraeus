#!/bin/bash -x 

cat > .sample.sql << 'EOF'
DROP DATABASE IF EXISTS class;
CREATE DATABASE class;
USE class;
CREATE TABLE students ( Student_No varchar(10), Surname varchar(20), Forename varchar(20));
INSERT INTO students VALUES ('20060101','Dickens','Charles');
INSERT INTO students VALUES ('20060102','ApGwilym','Dafydd');
INSERT INTO students VALUES ('20060103','Zola','Emile');
INSERT INTO students VALUES ('20060104','Mann','Thomas');
INSERT INTO students VALUES ('20060105','Stevenson','Robert');
COMMIT;
EOF

cat .sample.sql

kubectl -n piraeus-demo exec -it mysql-0 -c mysql -- mysql -t < .sample.sql

rm -f .sample.sql 
