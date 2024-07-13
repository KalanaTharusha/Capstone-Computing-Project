package com.example.student_support_system.dto.appointment;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalTimeSerializer;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalTime;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateTimeSlotRequestDTO {

    @JsonAlias("Mon")
    private List<String> monday;

    @JsonAlias("Tue")
    private List<String> tuesday;

    @JsonAlias("Wed")
    private List<String> wednesday;

    @JsonAlias("Thu")
    private List<String> thursday;

    @JsonAlias("Fri")
    private List<String> friday;

}
