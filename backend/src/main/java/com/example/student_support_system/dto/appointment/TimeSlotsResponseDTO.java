package com.example.student_support_system.dto.appointment;

import com.fasterxml.jackson.annotation.JsonAnyGetter;

import java.util.List;
import java.util.Map;

public class TimeSlotsResponseDTO {
    private Map<String, List<String>> timeSlotsMap;

    public TimeSlotsResponseDTO(Map<String, List<String>> timeSlotsMap) {
        this.timeSlotsMap = timeSlotsMap;
    }

    @JsonAnyGetter
    public Map<String, List<String>> getTimeSlotsMap() {
        return timeSlotsMap;
    }
}
