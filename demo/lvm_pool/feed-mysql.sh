#!/bin/bash -x 

cat > .sample.sql << 'EOF'
drop database if exists class;
create database class;
USE class;
create table students ( student_no varchar(10), surname varchar(20), forename varchar(20));
insert into students values ('20060101','Dickens','Charles');
insert into students values ('20060102','ApGwilym','Dafydd');
insert into students values ('20060103','Zola','Emile');
insert into students values ('20060104','Mann','Thomas');
insert into students values ('20060105','Stevenson','Robert');
commit;
EOF

kubectl -n piraeus exec -it mysql-0 -c mysql -- mysql -t < .sample.sql

rm -f .sample.sql 
