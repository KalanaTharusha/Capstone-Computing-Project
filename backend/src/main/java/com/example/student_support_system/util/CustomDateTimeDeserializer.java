package com.example.student_support_system.util;

import com.fasterxml.jackson.core.JacksonException;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.deser.std.StdDeserializer;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.format.ResolverStyle;

@Component
public class CustomDateTimeDeserializer extends StdDeserializer<LocalDateTime> {

    private final DateTimeFormatter dateTimeFormatter = new DateTimeFormatterBuilder()
            .appendPattern("dd-MM-yyyy HH:mm:ss")
            .parseLenient()
            .toFormatter()
            .withResolverStyle(ResolverStyle.LENIENT);

    public CustomDateTimeDeserializer() {
        super(CustomDateTimeDeserializer.class);
    }


    @Override
    public LocalDateTime deserialize(JsonParser p, DeserializationContext context) throws IOException, JacksonException {

        String date = p.getText();
        return LocalDateTime.parse(date, dateTimeFormatter);
    }
}
