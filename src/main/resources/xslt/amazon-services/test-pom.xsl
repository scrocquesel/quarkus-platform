<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pom="http://maven.apache.org/POM/4.0.0" xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xalan="http://xml.apache.org/xslt" exclude-result-prefixes="pom xalan">

    <xsl:output method="xml" indent="yes" xalan:indent-amount="2" />
    <xsl:strip-space elements="*" />

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/pom:project/pom:build/pom:plugins">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <plugin>
                <groupId>io.fabric8</groupId>
                <artifactId>docker-maven-plugin</artifactId>
                <version>0.38.0</version>
                <configuration>
                    <images>
                        <image>
                            <name>localstack/localstack:0.11.1</name>
                            <alias>aws-local-stack</alias>
                            <run>
                                <env>
                                    <SERVICES>s3,dynamodb,sns,sqs,kms,ssm,ses,secretsmanager</SERVICES>
                                    <START_WEB>0</START_WEB>
                                </env>
                                <ports>
                                    <port>8000:4569</port> <!-- Dynamodb -->
                                    <port>8008:4572</port> <!-- S3 -->
                                    <port>8009:4575</port> <!-- SNS -->
                                    <port>8010:4576</port> <!-- SQS -->
                                    <port>8011:4599</port> <!-- KMS -->
                                    <port>8012:4566</port> <!-- SES -->
                                    <port>8013:4593</port> <!-- IAM -->
                                    <port>8014:4583</port> <!-- SSM -->
                                    <port>8015:4584</port> <!-- Secrets Manager -->
                                </ports>
                                <log />
                                <wait>
                                    <time>30000</time>
                                    <log>^Ready\.$</log>
                                </wait>
                            </run>
                        </image>
                    </images>
                    <!--Stops all dynamodb images currently running, not just those we just started.
                      Useful to stop processes still running from a previously failed integration test run -->
                    <allContainers>true</allContainers>
                    <skip>${skipTests}</skip>
                </configuration>
                <executions>
                    <execution>
                        <id>docker-start</id>
                        <phase>compile</phase>
                        <goals>
                            <goal>stop</goal>
                            <goal>start</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>docker-stop</id>
                        <phase>post-integration-test</phase>
                        <goals>
                            <goal>stop</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
