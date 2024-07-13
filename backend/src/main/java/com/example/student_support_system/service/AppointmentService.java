package com.example.student_support_system.service;


import com.example.student_support_system.exception.EntityNotFoundException;
import com.example.student_support_system.model.appointment.Appointment;
import com.example.student_support_system.model.appointment.AppointmentStatus;
import com.example.student_support_system.model.appointment.AppointmentTimeSlot;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.repository.AppointmentRepository;
import com.example.student_support_system.repository.AppointmentTimeSlotRepository;
import jakarta.transaction.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AppointmentService {


    private final AppointmentRepository appointmentRepository;
    private final AppointmentTimeSlotRepository timeSlotRepository;

    private final FcmService fcmService;

    public AppointmentService(AppointmentRepository appointmentRepository, AppointmentTimeSlotRepository timeSlotRepository,FcmService fcmService){
        this.appointmentRepository = appointmentRepository;
        this.timeSlotRepository = timeSlotRepository;
        this.fcmService = fcmService;
    }


    public List<Appointment> getAllAppointments() {
        return appointmentRepository.findAll();
    }


    public Appointment getAppointmentById(Long id) {
        return appointmentRepository
                .findById(id)
                .orElseThrow(() -> new EntityNotFoundException(String.valueOf(id), Appointment.class));
    }

    public Appointment createAppointment(Appointment appointment) {
        fcmService.sendNotificationToUser(appointment.getDirectedUser().getId(), "New appointment",appointment.getReason());
        return appointmentRepository.save(appointment);
    }

    public void deleteAppointment(Long id) {
        appointmentRepository.deleteById(id);
    }

    public void updateAppointment(Appointment appointment) {
        getAppointmentById(appointment.getId()); //To make sure the appointment exists
        appointment.setDateLastUpdated(LocalDateTime.now());
        appointmentRepository.save(appointment);
    }

    public List<Appointment> getAppointmentsByDirectedUserId(Long id) {
        return appointmentRepository.findByDirectedUserId(id);
    }

    public List<Appointment> getAppointmentsByRequestedUserId(Long id) {
        return appointmentRepository.findByRequestedUserId(id);
    }

    public Page<Appointment> getAppointmentsWithPagination(int offset, int pageSize) {
        return appointmentRepository.findAll(PageRequest.of(offset, pageSize));
    }

    public Page<Appointment> getAppointmentsByDate(LocalDate startDate, LocalDate endDate, int offset, int pageSize){
        return appointmentRepository.findAppointmentsByRequestedDateBetween(startDate, endDate, PageRequest.of(offset, pageSize));
    }

    public Page<Appointment> searchAppointments(String term, LocalDate startDate, LocalDate endDate, int offset, int pageSize){
        return appointmentRepository.searchByUserFirstNameOrLastNameAndDateRange(term, startDate, endDate, PageRequest.of(offset, pageSize));
    }

    public AppointmentTimeSlot createAppointmentTimeSlot(AppointmentTimeSlot timeSlot){
        return timeSlotRepository.save(timeSlot);
    }

    public List<AppointmentTimeSlot> createAppointmentTimeSlots(List<AppointmentTimeSlot> timeSlots){
        return timeSlotRepository.saveAll(timeSlots);
    }

    @Transactional
    public void deleteAppointmentTimeSlots(UserAccount userId, String availableWeekday, LocalTime availableTime){
        timeSlotRepository.deleteByUserIdAndAvailableWeekdayAndAvailableTime(userId, availableWeekday, availableTime);
    }

    public List<AppointmentTimeSlot> getTimeSlotsByUserAndDateTime(UserAccount userId, LocalDate date){
        String weekday = date.getDayOfWeek().toString();
        System.out.println(weekday);

        List<AppointmentTimeSlot> timeSlots = timeSlotRepository.findAllByUserIdAndAvailableWeekdayIgnoreCase(userId, weekday);
        List<Appointment> appointmentsOnDate = appointmentRepository.findByDirectedUserIdAndRequestedDateAndRequestedTime(userId.getUserId(), date);

        for (Appointment appointment : appointmentsOnDate) {
            LocalTime appointmentTime = appointment.getRequestedTime();
            timeSlots.removeIf(ts -> ts.getAvailableTime().equals(appointmentTime));
        }

        return timeSlots;
    }

    //Get returned time slot from Repo and create a List
    public List<AppointmentTimeSlot> getTimeSlotsByUserId(UserAccount userId) {
        return timeSlotRepository.findByUserId(userId);
    }

    public Map<String, Long> appointmentStatistics() {

        LocalDate now = LocalDate.now();
        LocalDate firstDayOfMonth = now.withDayOfMonth(1);
        LocalDate lastDayOfMonth = now.withDayOfMonth(now.lengthOfMonth());

        Map<String, Long> statistics = new HashMap<>();
        statistics.put("total", appointmentRepository.count());
        statistics.put("totalAccepted", appointmentRepository.countByStatus(AppointmentStatus.ACCEPTED));
        statistics.put("totalPending", appointmentRepository.countByStatus(AppointmentStatus.PENDING));
        statistics.put("totalRejected", appointmentRepository.countByStatus(AppointmentStatus.REJECTED));
        statistics.put("thisMonth", appointmentRepository.countByRequestedDateBetween(firstDayOfMonth, lastDayOfMonth));
        statistics.put("thisMonthAccepted", appointmentRepository.countByStatusAndRequestedDateBetween(AppointmentStatus.ACCEPTED, firstDayOfMonth, lastDayOfMonth));
        statistics.put("thisMonthPending", appointmentRepository.countByStatusAndRequestedDateBetween(AppointmentStatus.PENDING, firstDayOfMonth, lastDayOfMonth));
        statistics.put("thisMonthRejected", appointmentRepository.countByStatusAndRequestedDateBetween(AppointmentStatus.REJECTED, firstDayOfMonth, lastDayOfMonth));

        return statistics;
    }


}
