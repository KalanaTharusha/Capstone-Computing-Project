package com.example.student_support_system.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.threeten.bp.LocalTime;

import com.example.student_support_system.model.Event;
import com.example.student_support_system.model.user.UserAccountRole;
import com.example.student_support_system.repository.EventRepository;

public class EventServiceTest {
    
    @InjectMocks
    private EventService eventService;

    @Mock
    private EventRepository eventRepository;

    @BeforeEach
    void setUp(){
        MockitoAnnotations.openMocks(this);
    }


    @Test
    public void testCreateEvent(){
        Event event = new Event(
            1L, 
            "Title",
            UserAccountRole.ACADEMIC_ADMINISTRATION,
            UserAccountRole.ACADEMIC_ADMINISTRATION,
            LocalDateTime.now(),
            LocalDateTime.now(), 
            "Description",
            LocalDate.of(2024, 05, 03),
            LocalTime.of(14, 15),
            LocalTime.of(18, 30)
        );

        when(eventRepository.save(event)).thenReturn(event);

        Event createdEvent = eventService.createEvent(event);

        assertEquals(event ,createdEvent);
        verify(eventRepository, times(1)).save(event);
    }

    @Test
    public void testDeleteEvent(){
        Event event = new Event(
            5L, 
            "Title", 
            UserAccountRole.ACADEMIC_ADMINISTRATION, 
            UserAccountRole.ACADEMIC_ADMINISTRATION,
            LocalDateTime.now(),
            LocalDateTime.now(),
            "Description",
            LocalDate.of(2024, 04, 27),
            LocalTime.of(8, 30),
            LocalTime.of(13, 45)
        );

        doNothing().when(eventRepository).deleteById(event.getId());
        eventService.deleteEvent(event.getId());
        verify(eventRepository, times(1)).deleteById(event.getId());
    }

    @Test
    public void testUpdateEvent() {
        Event event = new Event(
                1L,
                "Title",
                UserAccountRole.ACADEMIC_ADMINISTRATION,
                UserAccountRole.ACADEMIC_ADMINISTRATION,
                LocalDateTime.now(),
                LocalDateTime.now(),
                "Description",
                LocalDate.of(2024, 5, 3),
                LocalTime.of(14, 15),
                LocalTime.of(18, 30)
        );

        when(eventRepository.save(event)).thenReturn(event);
        Event updatedEvent = eventService.updateEvent(event);
        verify(eventRepository, times(1)).save(event);
        assertEquals(event, updatedEvent);
    }

    @Test
    public void testGetAllEvents() {
        List<Event> events = new ArrayList<>();
        events.add(new Event(
                1L,
                "Title 1",
                UserAccountRole.ACADEMIC_ADMINISTRATION,
                UserAccountRole.ACADEMIC_ADMINISTRATION,
                LocalDateTime.now(),
                LocalDateTime.now(),
                "Description 1",
                LocalDate.of(2024, 5, 3),
                LocalTime.of(14, 15),
                LocalTime.of(18, 30)
        ));
        events.add(new Event(
                2L,
                "Title 2",
                UserAccountRole.ACADEMIC_ADMINISTRATION,
                UserAccountRole.ACADEMIC_ADMINISTRATION,
                LocalDateTime.now(),
                LocalDateTime.now(),
                "Description 2",
                LocalDate.of(2024, 5, 4),
                LocalTime.of(15, 30),
                LocalTime.of(19, 0)
        ));

        when(eventRepository.findAll()).thenReturn(events);
        List<Event> getAllEvents = eventService.getAllEvents();
        verify(eventRepository, times(1)).findAll();
        assertEquals(events, getAllEvents);
    }

    @Test
    public void testGetEventById() {
        Event event = new Event(
                1L,
                "Title",
                UserAccountRole.ACADEMIC_ADMINISTRATION,
                UserAccountRole.ACADEMIC_ADMINISTRATION,
                LocalDateTime.now(),
                LocalDateTime.now(),
                "Description",
                LocalDate.of(2024, 5, 3),
                LocalTime.of(14, 15),
                LocalTime.of(18, 30)
        );
        when(eventRepository.findById(1L)).thenReturn(Optional.of(event));
        Event getEventByID = eventService.getEventById(1L);
        verify(eventRepository, times(1)).findById(1L);
        assertEquals(event,getEventByID);
    }

}
