package com.example.student_support_system.exception;

public class EntityNotFoundException extends RuntimeException{

    public EntityNotFoundException(String id, Class<?> entity) {
        super("The " + entity.getSimpleName().toLowerCase() + " with id '" + id + "' does not exist in our records");
    }
}
