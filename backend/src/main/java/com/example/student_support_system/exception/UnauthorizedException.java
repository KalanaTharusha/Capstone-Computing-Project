package com.example.student_support_system.exception;

public class UnauthorizedException extends RuntimeException {
    public UnauthorizedException(String message) {
        super("Unauthorized action: " + message);
    }
}
