package com.example.student_support_system.service;

import com.example.student_support_system.model.Announcement;
import com.example.student_support_system.model.AnnouncementCategory;
import com.example.student_support_system.model.appointment.Appointment;
import com.example.student_support_system.model.appointment.AppointmentStatus;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.repository.AnnouncementRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

public class AnnouncementServiceTest {

    @InjectMocks
    private AnnouncementService announcementService;

    @Mock
    private AnnouncementRepository announcementRepository;

    @Mock
    private FcmService fcmService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void createAnnouncementTest() throws JsonProcessingException {
        Announcement announcement = new Announcement(
                165L,
                AnnouncementCategory.IMPORTANT,
                "Test Tile",
                new ObjectMapper().readTree("[{\"insert\":\"Our mobile app is your central.\\n\"}]"),
                "Test Image",
                LocalDateTime.now(),
                new UserAccount(),
                LocalDateTime.now(),
                new UserAccount()
        );

        when(announcementRepository.save(announcement)).thenReturn(announcement);

        assertEquals(announcement, announcementService.createAnnouncement(announcement));
    }

    @Test
    public void updateAnnouncementTest() throws JsonProcessingException {

        Announcement announcement = new Announcement(
                165L,
                AnnouncementCategory.IMPORTANT,
                "Test Tile",
                new ObjectMapper().readTree("[{\"insert\":\"Our mobile app is your central.\\n\"}]"),
                "Test Image",
                LocalDateTime.now(),
                new UserAccount(),
                LocalDateTime.now(),
                new UserAccount()
        );

        when(announcementRepository.findById(announcement.getId())).thenReturn(Optional.of(announcement));
        when(announcementRepository.save(announcement)).thenReturn(announcement);

        assertEquals(
                announcement,
                announcementService.updateAnnouncement(
                        announcement.getId(),
                        new UserAccount(),
                        new Announcement(
                                165L,
                                AnnouncementCategory.IMPORTANT,
                                "Updated Tile",
                                new ObjectMapper().readTree("[{\"insert\":\"Our mobile app is your central.\\n\"}]"),
                                "Test Image",
                                LocalDateTime.now(),
                                new UserAccount(),
                                LocalDateTime.now(),
                                new UserAccount()
                        )
                )
        );
    }

    @Test
    public void deleteAnnouncementTest() throws JsonProcessingException {
        Announcement announcement = new Announcement(
                165L,
                AnnouncementCategory.IMPORTANT,
                "Test Tile",
                new ObjectMapper().readTree("[{\"insert\":\"Our mobile app is your central.\\n\"}]"),
                "Test Image",
                LocalDateTime.now(),
                new UserAccount(),
                LocalDateTime.now(),
                new UserAccount()
        );

        doNothing().when(announcementRepository).deleteById(announcement.getId());
        announcementService.deleteAnnouncement(announcement.getId());
        verify(announcementRepository, times(1)).deleteById(announcement.getId());
    }

    @Test
    public void getAnnouncementTest() throws JsonProcessingException {

        Announcement announcement = new Announcement(
                165L,
                AnnouncementCategory.IMPORTANT,
                "Test Tile",
                new ObjectMapper().readTree("[{\"insert\":\"Our mobile app is your central.\\n\"}]"),
                "Test Image",
                LocalDateTime.now(),
                new UserAccount(),
                LocalDateTime.now(),
                new UserAccount()
        );

        when(announcementRepository.findById(announcement.getId())).thenReturn(Optional.of(announcement));

        assertEquals(announcement, announcementService.getAnnouncement(announcement.getId()));

    }

    @Test
    public void getAllAnnouncementsTest() throws JsonProcessingException, Exception {

        Announcement announcement = new Announcement(
                165L,
                AnnouncementCategory.IMPORTANT,
                "Test Tile",
                new ObjectMapper().readTree("[{\"insert\":\"Our mobile app is your central.\\n\"}]"),
                "Test Image",
                LocalDateTime.now(),
                new UserAccount(),
                LocalDateTime.now(),
                new UserAccount()
        );

        List<Announcement> announcements = new ArrayList<>();
        announcements.add(announcement);

        when(announcementRepository.findAll()).thenReturn(announcements);

        assertEquals(announcements, announcementService.getAllAnnouncements());

    }

    @Test
    public void announcementNotificationTest() {
        Announcement announcement = new Announcement(
                165L,
                AnnouncementCategory.IMPORTANT,
                "Test Tile",
                null,
                "Test Image",
                LocalDateTime.now(),
                new UserAccount(),
                LocalDateTime.now(),
                new UserAccount()
        );

        when(announcementRepository.save(any(Announcement.class))).thenReturn(announcement);
        announcementService.createAnnouncement(announcement);

        verify(fcmService, times(1)).sendNotificationToAll(eq("New announcement"), eq("Test Tile"));
    }


}