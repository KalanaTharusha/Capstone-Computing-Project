package com.example.student_support_system.model;


import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.model.user.UserAccountRole;
import com.example.student_support_system.util.CustomDateTimeDeserializer;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Entity
@Table
public class Event {

    public Event(long l, String string, UserAccountRole academicAdministration, UserAccountRole academicAdministration2,
            LocalDateTime now, LocalDateTime now2, String string2, LocalDate of, org.threeten.bp.LocalTime of2,
            org.threeten.bp.LocalTime of3) {
        //TODO Auto-generated constructor stub
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @ManyToOne
    @JoinColumn(name = "createdUserId", referencedColumnName = "id", nullable = false)
    private UserAccount createdUser;

    @ManyToOne
    @JoinColumn(name = "lastUpdatedUserId", referencedColumnName = "id", nullable = false)
    private UserAccount lastUpdatedUser;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy HH:mm:ss")
    @JsonDeserialize(using = CustomDateTimeDeserializer.class)
    private LocalDateTime dateCreated;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "dd-MM-yyyy HH:mm:ss")
    @JsonDeserialize(using = CustomDateTimeDeserializer.class)
    private LocalDateTime dateLastUpdated;

    private LocalDate date;

    private LocalTime startTime;

    private LocalTime endTime;

}
