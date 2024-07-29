package com.example.student_support_system.service;

import com.example.student_support_system.brevo.BrevoTemplate;
import org.json.JSONObject;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@Service
public class EmailNotificationService {

    private final String BREVO_API_KEY = "";
    private final String BREVO_BASE_URL = "";

    public EmailNotificationService() {
    }

    public void sendEmailNotification(BrevoTemplate template, String to) {

        try {
            var client = HttpClient.newHttpClient();
            var request = HttpRequest.newBuilder(
                            URI.create(BREVO_BASE_URL))
                    .header("api-key", BREVO_API_KEY)
                    .method("POST", HttpRequest.BodyPublishers.ofString(String.format("{\"to\":[{\"email\":\"%s\"}],\"templateId\":%d,\"params\":%s}", to, template.templateId(), new JSONObject(template.params()).toString(2))))
                    .build();

            var response = client.send(request, HttpResponse.BodyHandlers.ofString());
            System.out.println(response.body());

        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }
}
