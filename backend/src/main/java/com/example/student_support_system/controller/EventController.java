package com.example.student_support_system.controller;


import com.example.student_support_system.dto.event.EventRequestDTO;
import com.example.student_support_system.brevo.templates.EventNotificationTemplate;
import com.example.student_support_system.model.Event;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.service.EmailNotificationService;
import com.example.student_support_system.service.EventService;
import com.example.student_support_system.service.UserAccountService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/events")
public class EventController {

    private final EventService eventService;

    private final UserAccountService userAccountService;

    private final EmailNotificationService emailNotificationService;

    public EventController(EventService eventService, UserAccountService userAccountService,EmailNotificationService emailNotificationService){
        this.eventService = eventService;
        this.userAccountService = userAccountService;
        this.emailNotificationService = emailNotificationService;
    }


    @GetMapping
    public ResponseEntity getAllEvents() {
        try {
            List<Event> events = eventService.getAllEvents();

            return ResponseEntity
                    .ok()
                    .body(events);
        } catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }


    @GetMapping("/{id}")
    public ResponseEntity getEventById(
            @PathVariable(name = "id") Long id
    ) {
        try {
            Event event = eventService.getEventById(id);

            return ResponseEntity
                    .ok()
                    .body(event);
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @PostMapping
    public ResponseEntity createEvent(
            @RequestAttribute(name = "userId") String userId,
            @RequestBody @Validated EventRequestDTO eventRequestDTO
    ) {
        try {
            UserAccount userAccount = userAccountService.getUserAccountByUserId(userId);

            Event event = new Event();
            event.setCreatedUser(userAccount);
            event.setLastUpdatedUser(userAccount);
            event.setName(eventRequestDTO.getName());
            event.setDate(eventRequestDTO.getDate());
            event.setStartTime(eventRequestDTO.getStartTime());
            event.setEndTime(eventRequestDTO.getEndTime());
            event.setDateCreated(LocalDateTime.now());
            event.setDateLastUpdated(LocalDateTime.now());

            List<UserAccount> userAccounts = userAccountService.getAllUserAccounts();

            for (UserAccount account : userAccounts) {
                emailNotificationService.sendEmailNotification(new EventNotificationTemplate(account.getFirstName(), event.getName(),event.getDate().toString(), event.getStartTime().toString(), event.getEndTime().toString()), account.getEmailAddress());
            }


            Event createdEvent = eventService.createEvent(event);


            return ResponseEntity
                    .ok()
                    .body(createdEvent);
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }


    @PatchMapping("/{id}")
    public ResponseEntity updateEvent(
            @RequestBody EventRequestDTO updateEventRequestDTO,
            @PathVariable(name = "id") Long existingEventId,
            @RequestAttribute(name = "userId") String userId
    ) {
            Event existingEvent = eventService.getEventById(existingEventId);

            existingEvent.setDate(updateEventRequestDTO.getDate());
            existingEvent.setDateLastUpdated(LocalDateTime.now());
            existingEvent.setEndTime(updateEventRequestDTO.getEndTime());
            existingEvent.setStartTime(updateEventRequestDTO.getStartTime());
            existingEvent.setName(updateEventRequestDTO.getName());
            existingEvent.setLastUpdatedUser(userAccountService.getUserAccountByUserId(userId));

            Event updatedEvent = eventService.updateEvent(existingEvent);

            return ResponseEntity
                    .ok(updatedEvent);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity deleteEvent(@PathVariable("id") Long id){
        try{
            eventService.deleteEvent(id);
            return ResponseEntity.ok()
                    .build();
        } catch (Exception e){
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to delete event"
            );
        }
    }
}
