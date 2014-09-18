Spring Boot init.d script
=========================

This script is meant to run a spring-boot project as a linux service using initd. 
It is meant as a template that can be reconfigured to an arbitrary war file. 

Use the variable names at the top of the script to customize to your specific project.

This file is known to work with CentOS, however, will not work yet for Ubuntu (due to the differences in `/etc/init.d/functions`).

Parameter | Description | Default Value
----------| ----------- | ----------
`PROJECT_NAME` | the name of the project, will also be used for the war file, log file, ... | `springboot`
`SERVICE_USER` | the user which should run the service | `root`
`SPRINGBOOTAPP_HOME` | base directory for the spring boot jar |  `/usr/local/$PROJECT_NAME`
`SPRINGBOOTAPP_WAR` | the jar/war file to start via `java -jar` | `$SPRINGBOOTAPP_HOME/$PROJECT_NAME.war`
`SPRINGBOOTAPP_JAVA` | java executable for spring boot app, change if you have multiple jdks installed | `$JAVA_HOME/bin/java`
