package com.example.student_support_system.repository;


import com.example.student_support_system.model.appointment.Appointment;
import com.example.student_support_system.model.appointment.AppointmentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    @Query("SELECT a FROM Appointment a WHERE a.directedUser.id = ?1 ORDER BY a.dateLastUpdated DESC")
    List<Appointment> findByDirectedUserId(Long id);

    @Query("SELECT a FROM Appointment a WHERE a.requestedUser.id = ?1 ORDER BY a.dateLastUpdated DESC")
    List<Appointment> findByRequestedUserId(Long id);

    @Query("SELECT a FROM Appointment a WHERE a.directedUser.userId = ?1 AND a.requestedDate = ?2 ORDER BY a.dateCreated ASC")
    List<Appointment> findByDirectedUserIdAndRequestedDateAndRequestedTime(String userId, LocalDate date);

    Page<Appointment> findAppointmentsByRequestedDateBetween(LocalDate start, LocalDate end, PageRequest pageRequest);

    @Query("SELECT a FROM Appointment a " +
            "WHERE (LOWER(a.requestedUser.firstName) LIKE LOWER(CONCAT('%', :term, '%')) " +
            "    OR LOWER(a.requestedUser.lastName) LIKE LOWER(CONCAT('%', :term, '%')) " +
            "    OR LOWER(a.directedUser.firstName) LIKE LOWER(CONCAT('%', :term, '%')) " +
            "    OR LOWER(a.directedUser.lastName) LIKE LOWER(CONCAT('%', :term, '%'))) " +
            "AND a.requestedDate BETWEEN :startDate AND :endDate")
    Page<Appointment> searchByUserFirstNameOrLastNameAndDateRange(String term, LocalDate startDate, LocalDate endDate, PageRequest pageRequest);

    long countByRequestedDateBetween(LocalDate start, LocalDate end);

    long countByStatus(AppointmentStatus status);

    long countByStatusAndRequestedDateBetween(AppointmentStatus status, LocalDate start, LocalDate end);

}
