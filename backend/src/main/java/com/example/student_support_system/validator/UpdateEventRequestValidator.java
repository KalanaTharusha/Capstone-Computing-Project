package com.example.student_support_system.validator;

import org.springframework.validation.Errors;
import org.springframework.validation.Validator;

public class UpdateEventRequestValidator implements Validator {

    @Override
    public boolean supports(Class<?> clazz) {
        return false;
    }

    @Override
    public void validate(Object target, Errors errors) {

    }
}