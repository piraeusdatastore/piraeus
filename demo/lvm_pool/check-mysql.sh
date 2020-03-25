#!/bin/bash -x

kubectl -n piraeus exec -it mysql-0 -c mysql -- mysql -e 'SHOW SLAVE HOSTS;'

kubectl -n piraeus exec -it mysql-0 -c mysql -- mysql -e 'USE class; SELECT * FROM students;'


