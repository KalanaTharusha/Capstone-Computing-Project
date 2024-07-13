package com.example.student_support_system.model.appointment;


import com.example.student_support_system.model.user.UserAccount;
import com.fasterxml.jackson.annotation.JsonIncludeProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Table (name = "appointment")
@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Appointment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String reason;

    @ManyToOne
    @JoinColumn(name = "requestedUserId", referencedColumnName = "userId", nullable = false)
    @JsonIncludeProperties({"userId", "firstName", "lastName", "emailAddress"})
    private UserAccount requestedUser;

    @ManyToOne
    @JoinColumn(name = "directedUserId", referencedColumnName = "userId", nullable = false)
    @JsonIncludeProperties({"userId", "firstName", "lastName", "emailAddress"})
    private UserAccount directedUser;

    @Column
    private LocalDate requestedDate;

    @Column
    private LocalTime requestedTime;

    @Column
    private LocalDateTime dateCreated;

    @Column
    private LocalDateTime dateLastUpdated;

    @Column
    private String location;

    @Column
    private AppointmentStatus status;

}
