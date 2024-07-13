package com.example.student_support_system.controller;

import com.example.student_support_system.dto.event.EventRequestDTO;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.util.TestResourceUtil;
import com.example.student_support_system.model.Event;
import com.example.student_support_system.service.EventService;
import com.example.student_support_system.service.UserAccountService;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.ResponseEntity;

import java.util.Collections;
import java.util.List;

@ExtendWith(MockitoExtension.class)
public class EventControllerTest {

    @Mock
    private UserAccountService userAccountService;

    @Mock
    private EventService eventService;

    @InjectMocks
    private EventController eventController;


    @Test
    public void testGetAllEvents() {
        try {
            Event event = TestResourceUtil.getObjectFromFile("Event.json", Event.class);

            List<Event> events = List.of(event, event);

            Mockito.when(eventService.getAllEvents())
                    .thenReturn(events);

            ResponseEntity responseEntity = eventController.getAllEvents();

            Assertions.assertEquals(200, responseEntity.getStatusCodeValue());
            Assertions.assertNotNull(responseEntity.getBody());
            Assertions.assertEquals(events, responseEntity.getBody());

        } catch (Exception exception) {
            Assertions.fail("getAllEventsTest failed", exception);
        }
    }

    @Test
    public void testGetEventById() {
        try {
            Event event = TestResourceUtil.getObjectFromFile("Event.json", Event.class);

            Mockito.when(eventService.getEventById(1L))
                    .thenReturn(event);

            ResponseEntity responseEntity = eventController.getEventById(1L);

            Assertions.assertEquals(200, responseEntity.getStatusCodeValue());
            Assertions.assertNotNull(responseEntity.getBody());
            Assertions.assertEquals(event, responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("getEventByIdTest failed", exception);
        }
    }

    @Test
    public void testCreateEvent() {
        try {
            EventRequestDTO eventRequestDTO = TestResourceUtil
                    .getObjectFromFile("EventRequestDTO.json", EventRequestDTO.class);

            Event event = TestResourceUtil.getObjectFromFile("Event.json", Event.class);

            UserAccount userAccount = TestResourceUtil.getObjectFromFile("UserAccount.json", UserAccount.class);

            Mockito.when(userAccountService.getUserAccountByUserId(Mockito.anyString()))
                    .thenReturn(userAccount);

            Mockito.when(eventService.createEvent(Mockito.any()))
                    .thenReturn(event);

            ResponseEntity responseEntity = eventController.createEvent("testUserId", eventRequestDTO);

            ArgumentCaptor<Event> createEventArgsCaptor = ArgumentCaptor.forClass(Event.class);

            Mockito.verify(eventService, Mockito.times(1))
                    .createEvent(createEventArgsCaptor.capture());

            Event createEventArgs = createEventArgsCaptor.getValue();
            Assertions.assertEquals(eventRequestDTO.getName(), createEventArgs.getName());
            Assertions.assertEquals(eventRequestDTO.getDate(), createEventArgs.getDate());
            Assertions.assertEquals(eventRequestDTO.getStartTime(), createEventArgs.getStartTime());
            Assertions.assertEquals(eventRequestDTO.getEndTime(), createEventArgs.getEndTime());

            Assertions.assertEquals(200, responseEntity.getStatusCodeValue());
            Assertions.assertNotNull(responseEntity.getBody());
            Assertions.assertEquals(event, responseEntity.getBody());

        } catch (Exception exception) {
            Assertions.fail("createEventTest failed", exception);
        }
    }

    @Test
    public void testUpdateEvent() {
        try {
            EventRequestDTO eventRequestDTO = TestResourceUtil
                    .getObjectFromFile("EventRequestDTO.json", EventRequestDTO.class);

            Event event = TestResourceUtil.getObjectFromFile("Event.json", Event.class);

            UserAccount userAccount = TestResourceUtil.getObjectFromFile("UserAccount.json", UserAccount.class);

            Mockito.when(userAccountService.getUserAccountByUserId(Mockito.anyString()))
                    .thenReturn(userAccount);

            Mockito.when(eventService.getEventById(11L))
                    .thenReturn(event);

            Mockito.when(eventService.updateEvent(Mockito.any()))
                    .thenReturn(event);

            ResponseEntity responseEntity = eventController.updateEvent(eventRequestDTO, 11L, "testUserId");

            ArgumentCaptor<Event> updateEventArgsCaptor = ArgumentCaptor.forClass(Event.class);

            Mockito.verify(eventService, Mockito.times(1))
                    .updateEvent(updateEventArgsCaptor.capture());

            Event updateEventArgs = updateEventArgsCaptor.getValue();

            Assertions.assertEquals(eventRequestDTO.getName(), updateEventArgs.getName());
            Assertions.assertEquals(eventRequestDTO.getDate(), updateEventArgs.getDate());
            Assertions.assertEquals(eventRequestDTO.getStartTime(), updateEventArgs.getStartTime());
            Assertions.assertEquals(eventRequestDTO.getEndTime(), updateEventArgs.getEndTime());
            Assertions.assertEquals(11L, updateEventArgs.getId());
            Assertions.assertEquals(200, responseEntity.getStatusCode().value());
            Assertions.assertNotNull(responseEntity.getBody());
            Assertions.assertEquals(event, responseEntity.getBody());

        } catch (Exception exception) {
            Assertions.fail("updateEventTest failed", exception);
        }
    }

    @Test
    public void testDeleteEvent() {
        try {
            Mockito.doNothing()
                    .when(eventService).deleteEvent(1L);

            ResponseEntity responseEntity = eventController.deleteEvent(1L);

            Assertions.assertEquals(200, responseEntity.getStatusCodeValue());
        } catch (Exception exception) {
            Assertions.fail("deleteEventTest failed", exception);
        }
    }
}
