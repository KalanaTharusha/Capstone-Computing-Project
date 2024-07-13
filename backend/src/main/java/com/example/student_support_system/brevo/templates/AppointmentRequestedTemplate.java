package com.example.student_support_system.brevo.templates;

import com.example.student_support_system.brevo.BrevoTemplate;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Map;

public class AppointmentRequestedTemplate implements BrevoTemplate {
    private String username;
    private String requestedStudentFirstname;
    private String requestedStudentLastname;
    private String appointmentDate;
    private String appointmentTime;
    private String reason;



    public AppointmentRequestedTemplate(String username,String requestedStudentFirstname,String requestedStudentLastname, String appointmentDate,String appointmentTime,String reason) {
        this.appointmentDate = appointmentDate;
        this.appointmentTime = appointmentTime;
        this.requestedStudentFirstname = requestedStudentFirstname;
        this.requestedStudentLastname = requestedStudentLastname;
        this.username = username;
        this.reason = reason;
    }

    @Override
    public int templateId() {
        return 8;
    }

    @Override
    public Map<String, ?> params() {
        String formattedDate = formatDate(appointmentDate);
        String formattedTime = formatTime(appointmentTime);
        return Map.of("username",username,"student",requestedStudentFirstname+" "+requestedStudentLastname,"date",formattedDate,"time",formattedTime,"reason",reason);
    }

    private String formatDate(String date){
        try{
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd MMMM yyyy");
            return simpleDateFormat.format(new SimpleDateFormat("yyyy-MM-dd").parse(date));
        }
        catch (Exception e){
            return date;
        }
    }

    private String formatTime(String time){
        try {
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("hh:mm a");
            return simpleDateFormat.format(new SimpleDateFormat("HH:mm").parse(time));
        }
        catch (ParseException e){
            return time;
        }
    }

}
