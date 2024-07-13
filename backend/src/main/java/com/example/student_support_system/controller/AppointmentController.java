package com.example.student_support_system.controller;

import com.example.student_support_system.brevo.templates.*;
import com.example.student_support_system.dto.appointment.CreateTimeSlotRequestDTO;
import com.example.student_support_system.dto.appointment.RequestAppointmentDTO;
import com.example.student_support_system.dto.appointment.TimeSlotsResponseDTO;
import com.example.student_support_system.dto.common.pageResponseDTO;
import com.example.student_support_system.model.appointment.Appointment;
import com.example.student_support_system.model.appointment.AppointmentStatus;
import com.example.student_support_system.model.appointment.AppointmentTimeSlot;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.service.AppointmentService;
import com.example.student_support_system.service.EmailNotificationService;
import com.example.student_support_system.service.FcmService;
import com.example.student_support_system.service.UserAccountService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {


    private final AppointmentService appointmentService;

    private final UserAccountService userAccountService;

    private final EmailNotificationService emailNotificationService;



    public AppointmentController(
            AppointmentService appointmentService,
            UserAccountService userAccountService,
            EmailNotificationService emailNotificationService,
            FcmService fcmService
    ) {
        this.appointmentService = appointmentService;
        this.userAccountService = userAccountService;
        this.emailNotificationService = emailNotificationService;

    }


    @GetMapping
    public ResponseEntity getAllAppointments(
            @RequestParam(required = false, name = "requestedUserId") String requestedUserId,
            @RequestParam(required = false, name = "directedUserId") String directedUserId
    ) {
        try {
            if (requestedUserId != null) {
                UserAccount user = userAccountService.getUserAccountByUserId(requestedUserId);
                List<Appointment> appointments = appointmentService.getAppointmentsByRequestedUserId(user.getId());
                return ResponseEntity
                        .ok()
                        .body(appointments);
            }

            if (directedUserId != null) {
                UserAccount user = userAccountService.getUserAccountByUserId(directedUserId);
                List<Appointment> appointments = appointmentService.getAppointmentsByDirectedUserId(user.getId());
                return ResponseEntity
                        .ok()
                        .body(appointments);
            }

            return ResponseEntity
                    .ok()
                    .body(appointmentService.getAllAppointments());
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @GetMapping("/pagination/{offset}/{pageSize}")
    public ResponseEntity getAppointmentsWithPagination(@PathVariable int offset, @PathVariable int pageSize){
        return ResponseEntity
                .ok()
                .body(new pageResponseDTO(
                        appointmentService.getAppointmentsWithPagination(offset, pageSize).getTotalPages(),
                        offset,
                        appointmentService.getAppointmentsWithPagination(offset, pageSize).getSize(),
                        appointmentService.getAppointmentsWithPagination(offset, pageSize).getContent()

                ));
    }

    @GetMapping("/pagination")
    public ResponseEntity getAppointmentsByRequestedDateWithPagination(
            @RequestParam(name = "startDate") LocalDate startDate,
            @RequestParam(name = "endDate") LocalDate endDate,
            @RequestParam(name = "offset") int offset,
            @RequestParam(name = "pageSize") int pageSize
    ){
        return ResponseEntity
                .ok()
                .body(new pageResponseDTO(
                        appointmentService.getAppointmentsByDate(startDate, endDate, offset, pageSize).getTotalPages(),
                        offset,
                        appointmentService.getAppointmentsByDate(startDate, endDate, offset, pageSize).getSize(),
                        appointmentService.getAppointmentsByDate(startDate, endDate, offset, pageSize).getContent()

                ));
    }

    @GetMapping("/search")
    public ResponseEntity searchAppointments(
            @RequestParam(name = "term") String term,
            @RequestParam(name = "startDate") LocalDate startDate,
            @RequestParam(name = "endDate") LocalDate endDate,
            @RequestParam(name = "offset") int offset,
            @RequestParam(name = "pageSize") int pageSize
    ){
        return ResponseEntity
                .ok()
                .body(new pageResponseDTO(
                        appointmentService.searchAppointments(term, startDate, endDate, offset, pageSize).getTotalPages(),
                        offset,
                        appointmentService.searchAppointments(term, startDate, endDate, offset, pageSize).getSize(),
                        appointmentService.searchAppointments(term, startDate, endDate, offset, pageSize).getContent()

                ));
    }

    @GetMapping("/{id}")
    public ResponseEntity getAppointmentById(@PathVariable String id) {
        try {
            Appointment appointment = appointmentService.getAppointmentById(Long.valueOf(id));

            return ResponseEntity.ok(appointment);
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @PostMapping
    public ResponseEntity createAppointment(@RequestBody RequestAppointmentDTO requestAppointmentDTO) {
        try {
            Appointment appointment = new Appointment();
            appointment.setDateLastUpdated(LocalDateTime.now());
            appointment.setDateCreated(LocalDateTime.now());
            appointment.setReason(requestAppointmentDTO.getReason());
            appointment.setRequestedDate(requestAppointmentDTO.getRequestedDate());
            appointment.setRequestedTime(requestAppointmentDTO.getRequestedTime());
            appointment.setRequestedUser(
                    userAccountService.getUserAccountByUserId(requestAppointmentDTO.getRequestedUserId())
            );
            appointment.setDirectedUser(
                    userAccountService.getUserAccountByUserId(requestAppointmentDTO.getDirectedUserId())
            );

            appointment.setStatus(AppointmentStatus.PENDING);

            Appointment createdAppointment = appointmentService.createAppointment(appointment);

            emailNotificationService.sendEmailNotification(new AppointmentConfirmationTemplate(appointment.getRequestedUser().getFirstName(), appointment.getRequestedDate().toString(), appointment.getRequestedTime().toString(), appointment.getDirectedUser().getFirstName(),appointment.getDirectedUser().getLastName()), appointment.getRequestedUser().getEmailAddress());
            emailNotificationService.sendEmailNotification(new AppointmentRequestedTemplate(appointment.getDirectedUser().getFirstName(), appointment.getRequestedUser().getFirstName(),appointment.getRequestedUser().getLastName(), appointment.getRequestedDate().toString(), appointment.getRequestedTime().toString(), appointment.getReason()), appointment.getDirectedUser().getEmailAddress());

            return ResponseEntity.ok(createdAppointment);
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @PatchMapping(path = "/{id}")
    public ResponseEntity updateAppointment(
            @PathVariable(value = "id") String appointmentId,
            @RequestParam(value = "status") String newAppointmentStatus,
            @RequestParam(value = "location") String location
    ) {
        try {
            Appointment existingAppointment = appointmentService.getAppointmentById(Long.valueOf(appointmentId));
            existingAppointment.setStatus(AppointmentStatus.valueOf(newAppointmentStatus));
            existingAppointment.setLocation(location);
            existingAppointment.setDateLastUpdated(LocalDateTime.now());
            appointmentService.updateAppointment(existingAppointment);

            if(existingAppointment.getStatus() == AppointmentStatus.ACCEPTED){
                emailNotificationService.sendEmailNotification(new AppointmentAcceptedTemplate(existingAppointment.getRequestedUser().getFirstName(),existingAppointment.getDirectedUser().getFirstName(), existingAppointment.getDirectedUser().getLastName(), existingAppointment.getRequestedDate().toString(), existingAppointment.getRequestedTime().toString(), existingAppointment.getLocation()), existingAppointment.getRequestedUser().getEmailAddress());
            }
            else if(existingAppointment.getStatus() == AppointmentStatus.REJECTED) {
                emailNotificationService.sendEmailNotification(new AppointmentRejectedTemplate(existingAppointment.getRequestedUser().getFirstName(),existingAppointment.getDirectedUser().getFirstName(), existingAppointment.getDirectedUser().getLastName(), existingAppointment.getRequestedDate().toString(), existingAppointment.getRequestedTime().toString()), existingAppointment.getRequestedUser().getEmailAddress());
            }

            Appointment updatedAppoint = appointmentService.getAppointmentById(existingAppointment.getId());

            return ResponseEntity.ok(updatedAppoint);
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }


    @DeleteMapping("/{id}")
    public ResponseEntity deleteAppointment(@PathVariable String id) {
        try {
            appointmentService.deleteAppointment(Long.valueOf(id));

            return ResponseEntity.ok("Appointment deleted successfully");
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @GetMapping("/staff")
    public ResponseEntity getAcademicStaff(){
        try {

            List<UserAccount> academicStaff = userAccountService.getAcademicStaff();

            return ResponseEntity
                    .ok(academicStaff);

        } catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @PostMapping("/timeslot/{userId}")
    public ResponseEntity createTimeSlots(@PathVariable String userId, @RequestBody CreateTimeSlotRequestDTO timeSlotDTO){
        try {

            UserAccount userAccount = userAccountService.getUserAccountByUserId(userId);

            List<AppointmentTimeSlot> newTimeSlots = new ArrayList<>();

            Map<String, List<String>> receivedTimeSlots = new HashMap<>();

            List<String> monday = timeSlotDTO.getMonday();
            List<String> tuesday = timeSlotDTO.getTuesday();
            List<String> wednesday = timeSlotDTO.getWednesday();
            List<String> thursday = timeSlotDTO.getThursday();
            List<String> friday = timeSlotDTO.getFriday();

            receivedTimeSlots.put("Monday", monday);
            receivedTimeSlots.put("Tuesday", tuesday);
            receivedTimeSlots.put("Wednesday", wednesday);
            receivedTimeSlots.put("Thursday", thursday);
            receivedTimeSlots.put("Friday", friday);

            for (var timeSlot : receivedTimeSlots.entrySet()) {
                if(timeSlot.getValue() != null) {
                    for (String ts: timeSlot.getValue()) {
                        AppointmentTimeSlot newTimeSlot = new AppointmentTimeSlot();
                        newTimeSlot.setUserId(userAccount);
                        newTimeSlot.setAvailableWeekday(timeSlot.getKey());
                        newTimeSlot.setAvailableTime(LocalTime.parse(ts));
                        newTimeSlots.add(newTimeSlot);
                    }
                }
            }

            return ResponseEntity
                    .ok(appointmentService.createAppointmentTimeSlots(newTimeSlots));

        } catch (Exception exception){
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @DeleteMapping("/timeslot/{userId}")
    public ResponseEntity deleteTimeSlots(@PathVariable String userId, @RequestBody CreateTimeSlotRequestDTO timeSlotDTO){
        try {

            UserAccount userAccount = userAccountService.getUserAccountByUserId(userId);

            List<AppointmentTimeSlot> newTimeSlots = new ArrayList<>();

            Map<String, List<String>> receivedTimeSlots = new HashMap<>();

            List<String> monday = timeSlotDTO.getMonday();
            List<String> tuesday = timeSlotDTO.getTuesday();
            List<String> wednesday = timeSlotDTO.getWednesday();
            List<String> thursday = timeSlotDTO.getThursday();
            List<String> friday = timeSlotDTO.getFriday();

            receivedTimeSlots.put("Monday", monday);
            receivedTimeSlots.put("Tuesday", tuesday);
            receivedTimeSlots.put("Wednesday", wednesday);
            receivedTimeSlots.put("Thursday", thursday);
            receivedTimeSlots.put("Friday", friday);

            for (var timeSlot : receivedTimeSlots.entrySet()) {
                if(timeSlot.getValue() != null) {
                    for (String ts: timeSlot.getValue()) {
                        appointmentService.deleteAppointmentTimeSlots(userAccount, timeSlot.getKey(), LocalTime.parse(ts));
                    }
                }
            }

            return ResponseEntity.noContent().build();

        } catch (Exception exception){
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @GetMapping("/timeslot/{userId}/{date}")
    public ResponseEntity getTimeSlotsByUserAndWeekday(@PathVariable String userId, @PathVariable String date){
        try {

            UserAccount user = userAccountService.getUserAccountByUserId(userId);

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            List<AppointmentTimeSlot> timeSlots = appointmentService.getTimeSlotsByUserAndDateTime(user, LocalDate.parse(date, formatter));

            List<LocalTime> ts = timeSlots.stream()
                    .map(AppointmentTimeSlot::getAvailableTime)
                    .toList();

            return ResponseEntity
                    .ok(ts);

        } catch (Exception exception){
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    //Get mapping for getting appointment time slots
    @GetMapping("/timeslot/{userId}")
    public ResponseEntity<TimeSlotsResponseDTO> getTimeSlotsByUserId(@PathVariable String userId) {
        try {
            // Retrieve time slots for the given userId
            UserAccount userAccount = userAccountService.getUserAccountByUserId(userId);
            List<AppointmentTimeSlot> timeSlots = appointmentService.getTimeSlotsByUserId(userAccount);

            // Prepare the response structure
            Map<String, List<String>> timeSlotsMap = new HashMap<>();
            timeSlotsMap.put("Monday", new ArrayList<>());
            timeSlotsMap.put("Tuesday", new ArrayList<>());
            timeSlotsMap.put("Wednesday", new ArrayList<>());
            timeSlotsMap.put("Thursday", new ArrayList<>());
            timeSlotsMap.put("Friday", new ArrayList<>());

            for (AppointmentTimeSlot timeSlot : timeSlots) {
                String weekday = timeSlot.getAvailableWeekday();
                List<String> slots = timeSlotsMap.get(weekday);
                if (slots != null) {
                    slots.add(timeSlot.getAvailableTime().toString());
                }
            }

            return ResponseEntity.ok(new TimeSlotsResponseDTO(timeSlotsMap));
        } catch (Exception exception) {
            return ResponseEntity.internalServerError().body(null);
        }
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Long>> getAppointmentStatistics() {
        try {
            Map<String, Long> stats = appointmentService.appointmentStatistics();
            return ResponseEntity.ok(stats);
        } catch (Exception exception) {
            return ResponseEntity.internalServerError().body(null);
        }
    }
}
