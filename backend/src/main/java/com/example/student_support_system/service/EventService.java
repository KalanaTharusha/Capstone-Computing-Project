package com.example.student_support_system.service;


import com.example.student_support_system.exception.EntityNotFoundException;
import com.example.student_support_system.model.Event;
import com.example.student_support_system.repository.EventRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class EventService {

    private final EventRepository eventRepository;


    public EventService(EventRepository eventRepository) {
        this.eventRepository = eventRepository;
    }

    public List<Event> getAllEvents() {
        return eventRepository.findAll();
    }

    public List<Event> getAllEvent(int pageNumber, int pageSize) {
        return eventRepository
                .findAll(PageRequest.of(pageNumber, pageSize, Sort.Direction.ASC))
                .getContent();
    }

    public Event getEventById(Long id) {
        return eventRepository
                .findById(id)
                .orElseThrow(() -> new EntityNotFoundException(String.valueOf(id), Event.class));
    }

    public Event createEvent(Event event) {
        return eventRepository.save(event);
    }

    public void deleteEvent(Long id) {
        eventRepository.deleteById(id);
    }

    public Event updateEvent(Event event) {
        return eventRepository.save(event);
    }
}
