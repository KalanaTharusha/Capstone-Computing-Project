package com.example.student_support_system.util;

import com.example.student_support_system.util.ApiUtil;
import com.example.student_support_system.util.logging.AppLogger;
import com.fasterxml.jackson.core.JsonFactory;
import com.google.gson.stream.JsonReader;

import java.io.File;
import java.io.FileReader;
import java.io.InputStream;

public class TestResourceUtil {

    public static <T> T getObjectFromFile(String filename, Class<T> clazz) {
        String json = getJsonFromFile(filename);
        return ApiUtil.fromJson(json, clazz);
    }

    public static String getJsonFromFile(String fileName) {
        try {
            FileUtil fileReaderUtil = new FileUtil();
            InputStream inputStream = fileReaderUtil.getFileInputStream(fileName);
            JsonFactory jsonFactory = new JsonFactory(ApiUtil.getObjectMapper());
            return jsonFactory.createParser(inputStream)
                    .readValueAsTree()
                    .toString();

        } catch (Exception exception) {
            AppLogger.error("Error reading file: " + fileName, exception);
            return null;
        }
    }
}
