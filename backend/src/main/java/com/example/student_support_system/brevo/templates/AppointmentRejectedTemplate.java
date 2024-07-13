package com.example.student_support_system.brevo.templates;

import com.example.student_support_system.brevo.BrevoTemplate;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Map;

public class AppointmentRejectedTemplate implements BrevoTemplate {

    private String username;
    private String appointmentWithFirstname;
    private String appointmentWithLastname;
    private String appointmentDate;
    private String appointmentTime;


    public AppointmentRejectedTemplate(String username, String appointmentWithFirstname, String appointmentWithLastname, String appointmentDate, String appointmentTime) {
        this.username = username;
        this.appointmentWithFirstname = appointmentWithFirstname;
        this.appointmentWithLastname = appointmentWithLastname;
        this.appointmentDate = appointmentDate;
        this.appointmentTime = appointmentTime;

    }

    public int templateId() {
        return 10;
    }

    public Map<String, ?> params() {
        String formattedDate = formatDate(appointmentDate);
        String formattedTime = formatTime(appointmentTime);
        return Map.of("username", username, "with", appointmentWithFirstname + " " + appointmentWithLastname, "date", formattedDate, "time", formattedTime, "location"," ");
    }

    private String formatDate(String date) {
        try {
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd MMMM yyyy");
            return simpleDateFormat.format(new SimpleDateFormat("yyyy-MM-dd").parse(date));
        } catch (ParseException e) {
            return date;
        }
    }

    private String formatTime(String time) {
        try {
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("hh:mm a");
            return simpleDateFormat.format(new SimpleDateFormat("HH:mm").parse(time));
        } catch (ParseException e) {
            return time;
        }
    }
}
