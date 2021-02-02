#!/bin/bash
# for generating demo ssl certifications and permits

docker run --rm -it -w /drop -v $(pwd):/drop openjdk:alpine \
    keytool -keyalg rsa -keysize 2048 -genkey -keystore keystore_linstor.jks \
            -storepass linstor -keypass linstor \
            -alias linstor_controller \
            -dname 'CN=localhost, OU=SecureUnit, O=ExampleOrg, L=Vienna, ST=Austria, C=AT'


docker run --rm -it -w /drop -v $(pwd):/drop openjdk:alpine \
    keytool -keyalg rsa -keysize 2048 -genkey -keystore client.jks \
            -storepass linstor -keypass linstor \
            -alias client1 \
            -dname 'CN=Client Cert, OU=client, O=Example, L=Vienna, ST=Austria, C=AT'

docker run --rm -it -w /drop -v $(pwd):/drop openjdk:alpine \
    keytool -importkeystore \
    -srcstorepass linstor -deststorepass linstor -keypass linstor \
    -srckeystore client.jks -destkeystore trustore_client.jks

docker run --rm -it -w /drop -v $(pwd):/drop openjdk:alpine \
    keytool -importkeystore -srckeystore client.jks -destkeystore client.p12 \
     -srcstorepass linstor -deststorepass linstor -keypass linstor \
    -srcalias client1 -srcstoretype jks -deststoretype pkcs12

openssl pkcs12 -in client.p12 -out client_with_pass.pem -passin pass:linstor -passout pass:linstor

openssl rsa -in client_with_pass.pem -out client1.pem -passin pass:linstor

openssl x509 -in client_with_pass.pem >> client1.pem

