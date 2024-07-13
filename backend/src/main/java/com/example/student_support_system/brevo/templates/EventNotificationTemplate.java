package com.example.student_support_system.brevo.templates;

import com.example.student_support_system.brevo.BrevoTemplate;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Map;

public class EventNotificationTemplate implements BrevoTemplate {

    private String username;
    private String event;
    private String date;
    private String startime;
    private String endtime;

    public EventNotificationTemplate(String username, String event, String date, String startime, String endtime) {
        this.username = username;
        this.event = event;
        this.date = date;
        this.startime = startime;
        this.endtime = endtime;
    }

    @Override
    public int templateId() {
        return 13;
    }

    @Override
    public Map<String, ?> params() {
        String formattedDate = formatDate(date);
        String formattedStartTime = formatTime(startime);
        String formattedEndTime = formatTime(endtime);
        return Map.of("username",username,"event",event,"date",formattedDate,"startTime",formattedStartTime,"endTime",formattedEndTime);
    }

    private String formatDate(String date){
        try {
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd MMMM yyyy");
            return simpleDateFormat.format(new SimpleDateFormat("yyyy-MM-dd").parse(date));
        }
        catch (ParseException e){
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
