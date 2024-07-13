package com.example.student_support_system.model.appointment;

import com.example.student_support_system.model.user.UserAccount;
import com.fasterxml.jackson.annotation.JsonIncludeProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

@Table(name = "appointment_time_slot")
@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AppointmentTimeSlot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "userId", referencedColumnName = "userId", nullable = false)
    @JsonIncludeProperties({"userId", "firstName", "lastName"})
    private UserAccount userId;

    @Column
    private String availableWeekday;

    @Column
    private LocalTime availableTime;

}
