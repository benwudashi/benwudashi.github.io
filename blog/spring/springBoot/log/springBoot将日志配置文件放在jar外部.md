## 首先maven打包时将日志配置文件排除掉 ##
```
<build>
        <finalName>jarName</finalName>
        <resources>
            <resource>
                <directory>${basedir}/src/main/resources</directory>
                <filtering>true</filtering>
                <includes>
                    <include>*.xml</include>
                </includes>
				<excludes>
                    <exclude>logback-spring.xml</exclude>
                </excludes>
            </resource>
            <resource>
                <directory>${basedir}/src/main/resources</directory>
                <excludes>
                    <exclude>dubbo-*.xml</exclude>
                </excludes>
				<includes>
                    <include>logback-spring.xml</include>
                </includes>
                <targetPath>${project.build.directory}</targetPath>
            </resource>
        </resources>
</build>
```
## 在application.properties中配置日志配置文件路径 ##
```logging.config=/home/app/logback-spring.xml```
附：
<?xml version="1.0" encoding="UTF-8" ?>
<!-- 日志组件启动时，打印调试信息，并监控此文件变化，周期300秒 -->
<configuration scan="true" scanPeriod="300 seconds" debug="false">
    <!--针对jul的性能优化 -->
    <contextListener class="ch.qos.logback.classic.jul.LevelChangePropagator">
        <resetJUL>true</resetJUL>
    </contextListener>
    <!-- 配置文件，包括此文件内的所有变量的配置 -->
    <property name="LOG_PATH" value="logs"/>
    <property name="APP_NAME" value="app"/>
    <!-- contextName主要是为了区分在一个web容器下部署多个应用启用jmx时，不会出现混乱 -->
    <contextName>${APP_NAME}</contextName>
    <!-- ***************************************************************** -->
    <!-- 配置输出到控制台，仅在开发测试时启用输出到控制台  -->
    <!-- ***************************************************************** -->
    <appender name="console" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level [%thread] %logger{0}:%L- %msg%n\n</pattern>
        </encoder>
    </appender>
    <root>
        <appender-ref ref="console"/>
    </root>
    <!-- ***************************************************************** -->
    <!-- info级别的日志appender -->
    <!-- ***************************************************************** -->
    <appender name="app-info" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_PATH}/${APP_NAME}-info-30dt.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${LOG_PATH}/${APP_NAME}-info-30dt.log.%d{yyyy-MM-dd}.%i</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>1024MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level [%thread] %logger{0}:%L- %msg%n\n</pattern>
        </encoder>
    </appender>
    <!-- ***************************************************************** -->
    <!-- error级别日志appender -->
    <!-- ***************************************************************** -->
    <appender name="app-error" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_PATH}/${APP_NAME}-error-30dt.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${LOG_PATH}/${APP_NAME}-error-30dt.%d{yyyy-MM-dd}.%i</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>1024MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
        </rollingPolicy>
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>ERROR</level>
        </filter>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level [%thread] %logger{0}:%L- %msg%n\n</pattern>
        </encoder>
    </appender>


    <!-- 时间滚动输出 level为 INFO 日志 -->
    <appender name="file-appender" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>${LOG_PATH}/record/${APP_NAME}-record-30dt.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${LOG_PATH}/record/${APP_NAME}-record-30dt.%d{yyyy-MM-dd}.%i</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>1024MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
        </rollingPolicy>
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>INFO</level>
        </filter>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level [%thread] %logger{0}:%L- %msg%n\n</pattern>
        </encoder>
    </appender>

    <!-- 根日志logger -->
    <root level="INFO">
        <appender-ref ref="app-info"/>
        <appender-ref ref="app-error"/>
    </root>

    <logger name="fileLogger" level="INFO" additivity="false">
        <appender-ref ref="file-appender"/>
    </logger>

</configuration>
