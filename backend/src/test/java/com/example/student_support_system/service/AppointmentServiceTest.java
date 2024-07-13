package com.example.student_support_system.service;

import com.example.student_support_system.model.appointment.Appointment;
import com.example.student_support_system.model.appointment.AppointmentStatus;
import com.example.student_support_system.model.appointment.AppointmentTimeSlot;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.repository.AppointmentRepository;
import com.example.student_support_system.repository.AppointmentTimeSlotRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

public class AppointmentServiceTest {

    @InjectMocks
    AppointmentService appointmentService;

    @Mock
    AppointmentRepository appointmentRepository;

    @Mock
    AppointmentTimeSlotRepository appointmentTimeSlotRepository;

    @Mock
    FcmService fcmService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void createAppointmentTest() {

        Appointment appointment = new Appointment(
                122L,
                "This should be the reason",
                new UserAccount(),
                new UserAccount(),
                LocalDate.now(),
                LocalTime.now(),
                LocalDateTime.now(),
                LocalDateTime.now(),
                "This should be the location",
                AppointmentStatus.PENDING
        );

        when(appointmentRepository.save(appointment)).thenReturn(appointment);
        assertEquals(appointment, appointmentService.createAppointment(appointment));
    }

    @Test
    public void getAppointmentsWithPaginationTest() {

        int offset = 1;
        int pageSize = 1;

        Appointment appointment = new Appointment(
                122L,
                "This should be the reason",
                new UserAccount(),
                new UserAccount(),
                LocalDate.now(),
                LocalTime.now(),
                LocalDateTime.now(),
                LocalDateTime.now(),
                "This should be the location",
                AppointmentStatus.PENDING
        );

        Pageable pageable = PageRequest.of(offset, pageSize);
        List<Appointment> appointments = new ArrayList<>();
        appointments.add(appointment);

        when(appointmentRepository.findAll(pageable)).thenReturn(new PageImpl<>(appointments, pageable, appointments.size()));

        Page<Appointment> resultPage = appointmentService.getAppointmentsWithPagination(offset, pageSize);

        assertEquals(pageSize, resultPage.getContent().size());
        assertEquals(appointments.get(0).getId(), resultPage.getContent().get(0).getId());
        verify(appointmentRepository, times(1)).findAll(pageable);
    }

    @Test
    public void searchAppointmentsTest() {

        int offset = 1;
        int pageSize = 1;

        Appointment appointment = new Appointment(
                122L,
                "This should be the reason",
                UserAccount.builder().id(1L).firstName("").lastName("").build(),
                UserAccount.builder().id(1L).firstName("").lastName("").build(),
                LocalDate.of(2024, 3, 12),
                LocalTime.now(),
                LocalDateTime.now(),
                LocalDateTime.now(),
                "This should be the location",
                AppointmentStatus.PENDING
        );

        Pageable pageable = PageRequest.of(offset, pageSize);
        List<Appointment> appointments = new ArrayList<>();
        appointments.add(appointment);

        when(appointmentRepository.searchByUserFirstNameOrLastNameAndDateRange(
                "",
                LocalDate.of(2024, 3, 1),
                LocalDate.of(2024, 3, 31),
                PageRequest.of(offset, pageSize))
        ).thenReturn(new PageImpl<>(appointments, pageable, appointments.size()));

        Page<Appointment> resultPage = appointmentService.searchAppointments("", LocalDate.of(2024, 3, 1), LocalDate.of(2024, 3, 31), offset, pageSize);

        assertEquals(pageSize, resultPage.getContent().size());
        assertEquals(appointments.get(0).getId(), resultPage.getContent().get(0).getId());
        verify(appointmentRepository, times(1)).searchByUserFirstNameOrLastNameAndDateRange(
                "",
                LocalDate.of(2024, 3, 1),
                LocalDate.of(2024, 3, 31),
                PageRequest.of(offset, pageSize));
    }

    @Test
    public void getAppointmentsByDateTest() {

        int offset = 1;
        int pageSize = 1;

        Appointment appointment = new Appointment(
                122L,
                "This should be the reason",
                UserAccount.builder().id(1L).firstName("").lastName("").build(),
                UserAccount.builder().id(1L).firstName("").lastName("").build(),
                LocalDate.of(2024, 3, 12),
                LocalTime.now(),
                LocalDateTime.now(),
                LocalDateTime.now(),
                "This should be the location",
                AppointmentStatus.PENDING
        );

        Pageable pageable = PageRequest.of(offset, pageSize);
        List<Appointment> appointments = new ArrayList<>();
        appointments.add(appointment);

        when(appointmentRepository.findAppointmentsByRequestedDateBetween(
                LocalDate.of(2024, 3, 1),
                LocalDate.of(2024, 3, 31),
                PageRequest.of(offset, pageSize))
        ).thenReturn(new PageImpl<>(appointments, pageable, appointments.size()));

        Page<Appointment> resultPage = appointmentService.getAppointmentsByDate(LocalDate.of(2024, 3, 1), LocalDate.of(2024, 3, 31), offset, pageSize);

        assertEquals(pageSize, resultPage.getContent().size());
        assertEquals(appointments.get(0).getId(), resultPage.getContent().get(0).getId());
        verify(appointmentRepository, times(1)).findAppointmentsByRequestedDateBetween(
                LocalDate.of(2024, 3, 1),
                LocalDate.of(2024, 3, 31),
                PageRequest.of(offset, pageSize));
    }

    @Test
    public void getTimeSlotsByUserIdTest() {
        UserAccount userAccount = new UserAccount();
        when(appointmentTimeSlotRepository.findByUserId(userAccount)).thenReturn(new ArrayList<>());
        assertEquals(new ArrayList<>(), appointmentService.getTimeSlotsByUserId(userAccount));
    }

    @Test
    public void deleteTimeSlotTest() {
        UserAccount userAccount = new UserAccount();
        appointmentService.deleteAppointmentTimeSlots(userAccount, "Monday", LocalTime.now());
    }

    @Test
    public void createAppointmentTimeSlotTest() {
        UserAccount userAccount = new UserAccount();
        appointmentService.createAppointmentTimeSlot(new AppointmentTimeSlot(1L, userAccount, "Monday", LocalTime.now()));
    }

    @Test
    public void deleteAppointmentTimeSlotsTest() {
        UserAccount userAccount = new UserAccount();
        String availableWeekday = "Monday";
        LocalTime availableTime = LocalTime.of(10, 0);

        appointmentService.deleteAppointmentTimeSlots(userAccount, availableWeekday, availableTime);
        verify(appointmentTimeSlotRepository).deleteByUserIdAndAvailableWeekdayAndAvailableTime(userAccount, availableWeekday, availableTime);
    }

    @Test
    public void createAppointmentTimeSlotsTest() {
        AppointmentTimeSlot timeSlot1 = new AppointmentTimeSlot(1L, new UserAccount(), "Monday", LocalTime.of(10, 0));
        AppointmentTimeSlot timeSlot2 = new AppointmentTimeSlot(2L, new UserAccount(), "Tuesday", LocalTime.of(11, 0));
        List<AppointmentTimeSlot> timeSlots = Arrays.asList(timeSlot1, timeSlot2);

        when(appointmentTimeSlotRepository.saveAll(timeSlots)).thenReturn(timeSlots);
        appointmentService.createAppointmentTimeSlots(timeSlots);
        verify(appointmentTimeSlotRepository).saveAll(timeSlots);
    }


    @Test
    public void appointmentNotificationTest() {
        when(appointmentRepository.save(any(Appointment.class))).thenAnswer(invocation -> invocation.getArgument(0));

        UserAccount requestedUser = new UserAccount();
        requestedUser.setId(122L);
        UserAccount directedUser = new UserAccount();
        directedUser.setId(444L);

        Appointment appointment = new Appointment(
                122L,
                "This should be the reason",
                requestedUser,
                directedUser,
                LocalDate.now(),
                LocalTime.now(),
                LocalDateTime.now(),
                LocalDateTime.now(),
                "This should be the location",
                AppointmentStatus.PENDING
        );

        when(appointmentRepository.save(any(Appointment.class))).thenReturn(appointment);
        appointmentService.createAppointment(appointment);

        verify(fcmService, times(1)).sendNotificationToUser(anyLong(), eq("New appointment"), eq("This should be the reason"));

    }

}
