#!/bin/sh -e
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

##
## @fn build-guacamole.sh
##
## Builds Guacamole, saving "guacamole.war" and all applicable extension .jars
## using the guacamole-client source contained within the given directory.
## Extension files will be grouped by their associated type, with all MySQL
## files being placed within the "mysql/" subdirectory of the destination, all
## PostgreSQL files being placed within the "postgresql/" subdirectory of the
## destination, etc.
##
## @param BUILD_DIR
##     The directory which currently contains the guacamole-client source and
##     in which the build should be performed.
##
## @param DESTINATION
##     The directory to save guacamole.war within, along with all extension
##     .jars.  Note that this script will create extension-specific
##     subdirectories within this directory, and files will thus be grouped by
##     extension type.
##

BUILD_DIR="$1"
DESTINATION="$2"

#
# Create destination, if it does not yet exist
#

mkdir -p "$DESTINATION"

#
# Build guacamole.war and all extensions
#

cd "$BUILD_DIR"
mvn -Drat.skip=true package 

#
# Copy guacamole.war to destination
#

cp guacamole/target/*.war "$DESTINATION/guacamole.war"

#
# Copy JDBC auth extensions and SQL scripts
#

tar -xzf extensions/guacamole-auth-jdbc/modules/guacamole-auth-jdbc-dist/target/*.tar.gz \
    -C "$DESTINATION"                                   \
    --wildcards                                         \
    --no-anchored                                       \
    --strip-components=1                                \
    "*.jar"                                             \
    "*.sql"

#
# Download MySQL JDBC driver
#

echo "Downloading MySQL Connector/J ..."
curl -L "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.35.tar.gz" | \
tar -xz                        \
    -C "$DESTINATION/mysql/"   \
    --wildcards                \
    --no-anchored              \
    --no-wildcards-match-slash \
    --strip-components=1       \
    "mysql-connector-*.jar"

#
# Download PostgreSQL JDBC driver
#

echo "Downloading PostgreSQL JDBC driver ..."
curl -L "https://jdbc.postgresql.org/download/postgresql-9.4-1201.jdbc41.jar" > "$DESTINATION/postgresql/postgresql-9.4-1201.jdbc41.jar"

#
# Download PostgreSQL JDBC driver
#

echo "Downloading JWT driver ..."
mkdir -p "$DESTINATION/jwt/lib"
curl -L "https://github.com/aiden0z/guacamole-auth-jwt/releases/download/0.9.14/guacamole-auth-jwt-0.9.14.jar" > "$DESTINATION/jwt/guacamole-auth-jwt-0.9.14.jar"
curl -L "https://repo1.maven.org/maven2/io/jsonwebtoken/jjwt/0.7.0/jjwt-0.7.0.jar" > "$DESTINATION/jwt/lib/jjwt-0.7.0.jar"
curl -L "http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.9.9.3/jackson-databind-2.9.9.3.jar" > "$DESTINATION/jwt/lib/jackson-databind-2.9.9.3.jar"
curl -L "http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.9.9/jackson-core-2.9.9.jar" > "$DESTINATION/jwt/lib/jackson-core-2.9.9.jar"
curl -L "http://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/2.9.9/jackson-annotations-2.9.9.jar" > "$DESTINATION/jwt/lib/jackson-annotations-2.9.9.jar"


#curl -L "https://github.com/google/guice/releases/download/4.2.2/guice-4.2.2.jar" > "$DESTINATION/jwt/guice-4.2.2.jar"


#
# Copy LDAP auth extension and schema modifications
#

mkdir -p "$DESTINATION/ldap"
tar -xzf extensions/guacamole-auth-ldap/target/*.tar.gz \
    -C "$DESTINATION/ldap"                              \
    --wildcards                                         \
    --no-anchored                                       \
    --xform="s#.*/##"                                   \
    "*.jar"                                             \
    "*.ldif"

