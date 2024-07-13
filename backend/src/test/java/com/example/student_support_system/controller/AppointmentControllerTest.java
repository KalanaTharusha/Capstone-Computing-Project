package com.example.student_support_system.controller;

import com.example.student_support_system.dto.appointment.CreateTimeSlotRequestDTO;
import com.example.student_support_system.dto.appointment.RequestAppointmentDTO;
import com.example.student_support_system.dto.appointment.TimeSlotsResponseDTO;
import com.example.student_support_system.model.appointment.Appointment;
import com.example.student_support_system.model.appointment.AppointmentTimeSlot;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.service.AppointmentService;
import com.example.student_support_system.service.EmailNotificationService;
import com.example.student_support_system.service.UserAccountService;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@ExtendWith(MockitoExtension.class)
public class AppointmentControllerTest {

    @Mock
    private AppointmentService appointmentService;

    @Mock
    private UserAccountService userAccountService;

    @Mock
    private EmailNotificationService emailNotificationService;

    @InjectMocks
    private AppointmentController appointmentController;

    @Test
    void testGetAllAppointments() {
        try {
            UserAccount user = new UserAccount();
            user.setId(1L);
            Mockito.when(userAccountService.getUserAccountByUserId("testUserId")).thenReturn(user);
            Mockito.when(appointmentService.getAppointmentsByRequestedUserId(1L)).thenReturn(Collections.singletonList(new Appointment()));

            ResponseEntity responseEntity = appointmentController.getAllAppointments("testUserId", null);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("getAllAppointmentsTest failed", exception);
        }
    }

    @Test
    void testCreateAppointment() {
        try {
            RequestAppointmentDTO requestAppointmentDTO = new RequestAppointmentDTO();
            requestAppointmentDTO.setRequestedUserId("testUserId");
            requestAppointmentDTO.setDirectedUserId("testDirectedUserId");
            requestAppointmentDTO.setRequestedDate(LocalDate.now());
            requestAppointmentDTO.setRequestedTime(LocalTime.now());
            Mockito.when(userAccountService.getUserAccountByUserId(Mockito.anyString())).thenReturn(new UserAccount());
            Mockito.when(userAccountService.getUserAccountByUserId(Mockito.anyString())).thenReturn(new UserAccount());
            Mockito.when(appointmentService.createAppointment(Mockito.any())).thenReturn(new Appointment());
            Mockito.doNothing().when(emailNotificationService).sendEmailNotification(Mockito.any(), Mockito.any());
            ResponseEntity responseEntity = appointmentController.createAppointment(requestAppointmentDTO);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("createAppointmentTest failed", exception);
        }
    }

    @Test
    void testGetAppointmentById() {
        try {
            Appointment appointment = new Appointment();
            Mockito.when(appointmentService.getAppointmentById(1L)).thenReturn(appointment);

            ResponseEntity responseEntity = appointmentController.getAppointmentById("1");

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail(exception);
        }
    }

    @Test
    void testUpdateAppointment() {
        try {
            Appointment appointment = new Appointment();
            Mockito.when(appointmentService.getAppointmentById(Mockito.anyLong())).thenReturn(appointment);
            Mockito.doNothing().when(appointmentService).updateAppointment(Mockito.any());
            ResponseEntity responseEntity = appointmentController.updateAppointment("1", "PENDING", "LOCATION");

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
        } catch (Exception exception) {
            Assertions.fail(exception);
        }
    }

    @Test
    void testDeleteAppointment() {
        try {
            Mockito.doNothing().when(appointmentService).deleteAppointment(1L);

            ResponseEntity responseEntity = appointmentController.deleteAppointment("1");

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertEquals("Appointment deleted successfully", responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("deleteAppointmentTest failed", exception);
        }
    }

    @Test
    void testGetAcademicStaff() {
        try {
            UserAccount userAccount = new UserAccount();
            Mockito.when(userAccountService.getAcademicStaff()).thenReturn(Collections.singletonList(userAccount));

            ResponseEntity responseEntity = appointmentController.getAcademicStaff();

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("getAcademicStaffTest failed", exception);
        }
    }

    @Test
    void testCreateTimeSlots() {
        try {
            CreateTimeSlotRequestDTO requestDTO = new CreateTimeSlotRequestDTO();
            requestDTO.setMonday(Collections.singletonList("09:00"));
            Mockito.when(userAccountService.getUserAccountByUserId("1")).thenReturn(new UserAccount());

            ResponseEntity responseEntity = appointmentController.createTimeSlots("1", requestDTO);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("createTimeSlotsTest failed", exception);
        }
    }

    @Test
    void testDeleteTimeSlots() {
        try {
            CreateTimeSlotRequestDTO requestDTO = new CreateTimeSlotRequestDTO();
            requestDTO.setMonday(Collections.singletonList("09:00"));
            Mockito.when(userAccountService.getUserAccountByUserId("1")).thenReturn(new UserAccount());
            Mockito.doNothing().when(appointmentService).deleteAppointmentTimeSlots(Mockito.any(), Mockito.anyString(), Mockito.any());

            ResponseEntity responseEntity = appointmentController.deleteTimeSlots("1", requestDTO);

            Assertions.assertEquals(HttpStatus.NO_CONTENT, responseEntity.getStatusCode());

        } catch (Exception exception) {
            Assertions.fail("deleteTimeSlotsTest failed", exception);
        }
    }

    @Test
    void testGetTimeSlotsByUserAndWeekday() {
        try {
            UserAccount userAccount = new UserAccount();
            LocalDate date = LocalDate.of(2022, 4, 1);
            Mockito.when(userAccountService.getUserAccountByUserId("1")).thenReturn(userAccount);
            Mockito.when(appointmentService.getTimeSlotsByUserAndDateTime(userAccount, date)).thenReturn(Collections.singletonList(new AppointmentTimeSlot()));

            ResponseEntity<List<LocalTime>> responseEntity = appointmentController.getTimeSlotsByUserAndWeekday("1", "2022-04-01");

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("getTimeSlotsByUserAndWeekdayTest failed", exception);
        }
    }


    @Test
    void testGetTimeSlotsByUserId() {
        try {
            AppointmentTimeSlot appointmentTimeSlot = new AppointmentTimeSlot();
            appointmentTimeSlot.setAvailableTime(LocalTime.of(9, 0));
            appointmentTimeSlot.setAvailableWeekday("Monday");
            UserAccount userAccount = new UserAccount();
            Mockito.when(appointmentService.getTimeSlotsByUserId(userAccount)).thenReturn(Collections.singletonList(appointmentTimeSlot));
            Mockito.when(userAccountService.getUserAccountByUserId(Mockito.any())).thenReturn(userAccount);
            ResponseEntity<TimeSlotsResponseDTO> responseEntity = appointmentController.getTimeSlotsByUserId("1");

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("getTimeSlotsByUserIdTest failed", exception);
        }
    }

    @Test
    void testGetAppointmentsWithPagination() {
        try {

            int offset = 0;
            int pageSize = 10;
            Pageable pageable = PageRequest.of(offset, pageSize);
            List<Appointment> appointments = new ArrayList<>();
            Page<Appointment> appointmentPage = new PageImpl<>(appointments, pageable, appointments.size());

            Mockito.when(appointmentService.getAppointmentsWithPagination(offset, pageSize)).thenReturn(appointmentPage);

            ResponseEntity responseEntity = appointmentController.getAppointmentsWithPagination(offset, pageSize);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());

        } catch (Exception exception) {
            Assertions.fail("getAppointmentsWithPagination test failed", exception);
        }
    }

    @Test
    void testGetAppointmentsByRequestedDateWithPagination() {
        try {

            int offset = 0;
            int pageSize = 10;
            LocalDate startDate = LocalDate.of(2024, 4, 1);
            LocalDate endDate = startDate.plusDays(7);
            Pageable pageable = PageRequest.of(offset, pageSize);
            List<Appointment> appointments = new ArrayList<>();
            Page<Appointment> appointmentPage = new PageImpl<>(appointments, pageable, appointments.size());

            Mockito.when(appointmentService.getAppointmentsByDate(startDate, endDate, offset, pageSize)).thenReturn(appointmentPage);

            ResponseEntity responseEntity = appointmentController.getAppointmentsByRequestedDateWithPagination(startDate, endDate, offset, pageSize);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());

        } catch (Exception exception) {
            Assertions.fail("getAppointmentsByRequestedDateWithPagination test failed", exception);
        }
    }

    @Test
    void testSearchAppointments() {
        try {

            String term = "any";
            int offset = 0;
            int pageSize = 10;
            LocalDate startDate = LocalDate.of(2024, 4, 1);
            LocalDate endDate = startDate.plusDays(7);
            Pageable pageable = PageRequest.of(offset, pageSize);
            List<Appointment> appointments = new ArrayList<>();
            Page<Appointment> appointmentPage = new PageImpl<>(appointments, pageable, appointments.size());

            Mockito.when(appointmentService.searchAppointments(term, startDate, endDate, offset, pageSize)).thenReturn(appointmentPage);

            ResponseEntity responseEntity = appointmentController.searchAppointments(term, startDate, endDate, offset, pageSize);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());

        } catch (Exception exception) {
            Assertions.fail("searchAppointments test failed", exception);
        }
    }
}
