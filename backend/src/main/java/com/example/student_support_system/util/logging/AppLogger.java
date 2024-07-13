package com.example.student_support_system.util.logging;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class AppLogger {

    private static final Logger debugLogger = LogManager.getLogger("DebugLogger");

    private static final Logger rootLogger = LogManager.getRootLogger();

    public static void debug(String message) {
        debugLogger.debug(message);
    }

    public static void info(String message) {
        rootLogger.info(message);
    }


    public static void error(String message) {
        rootLogger.error(message);
    }

    public static void error(String message, Exception exception) {
        rootLogger.error(message, exception);
    }

    public static void warn(String message) {
        rootLogger.warn(message);
    }
}
