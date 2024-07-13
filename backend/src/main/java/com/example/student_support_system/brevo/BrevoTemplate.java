package com.example.student_support_system.brevo;

import java.util.Map;

public interface BrevoTemplate {
    int templateId();

    Map<String, ?> params();

}

