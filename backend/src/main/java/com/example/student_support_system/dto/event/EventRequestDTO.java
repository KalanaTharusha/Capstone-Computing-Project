package com.example.student_support_system.dto.event;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class EventRequestDTO {

    private String name;

    private LocalDate date;

    private LocalTime startTime;

    private LocalTime endTime;
}
