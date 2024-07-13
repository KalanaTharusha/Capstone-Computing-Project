package com.example.student_support_system.dto.appointment;


import com.example.student_support_system.model.appointment.AppointmentStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateAppointmentRequestDTO {

    private AppointmentStatus status;
}
