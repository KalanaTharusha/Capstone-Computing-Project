package com.example.student_support_system.repository;

import com.example.student_support_system.model.appointment.AppointmentTimeSlot;
import com.example.student_support_system.model.user.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalTime;
import java.util.List;

public interface AppointmentTimeSlotRepository extends JpaRepository<AppointmentTimeSlot, Long> {
    List<AppointmentTimeSlot> findAllByUserIdAndAvailableWeekdayIgnoreCase(UserAccount userId, String availableWeekday);
    void deleteByUserIdAndAvailableWeekdayAndAvailableTime(UserAccount userId, String availableWeekday, LocalTime availableTime);

    List<AppointmentTimeSlot> findByUserId(UserAccount userId);

}
