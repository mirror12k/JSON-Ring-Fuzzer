#!/bin/sh


git clone https://github.com/stleary/JSON-java

cd JSON-java && chmod +x gradlew && ./gradlew build
mv JSON-java/build/libs/JSON-java-*-SNAPSHOT.jar json-java.jar

javac -cp .:json-java.jar ProcessJSON.java
