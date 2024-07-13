package com.example.student_support_system.service;

import com.example.student_support_system.exception.EntityNotFoundException;
import com.example.student_support_system.model.ticket.Ticket;
import com.example.student_support_system.model.ticket.TicketCategory;
import com.example.student_support_system.model.ticket.TicketStatus;
import com.example.student_support_system.repository.TicketRepository;
import com.example.student_support_system.util.TicketSpecification;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.Ticker;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class TicketService {

    private final TicketRepository ticketRepository;

    public TicketService(TicketRepository ticketRepository) {
        this.ticketRepository = ticketRepository;
    }

    public List<Ticket> getAllTickets() {
        return ticketRepository.findAll();
    }

    public Map<String, Integer> getTicketStats() {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("total", ticketRepository.findAll().size());
        stats.put("pending", ticketRepository.countByStatus(TicketStatus.PENDING));
        stats.put("replied", ticketRepository.countByStatus(TicketStatus.REPLIED));
        stats.put("closed", ticketRepository.countByStatus(TicketStatus.CLOSED));
        return stats;
    }

    public Page<Ticket> searchTickets(String term, String status, String category, String order, int pageNo,
            int pageSize) {

        Specification<Ticket> spec = TicketSpecification.withParams(term, category, status, order, pageNo, pageSize);
        return ticketRepository.findAll(spec, PageRequest.of(pageNo, pageSize));

    }

    public Ticket getTicketById(Long id) {
        return ticketRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(String.valueOf(id), Ticket.class));
    }

    public Ticket createTicket(Ticket ticket) {
        if (ticket.getStatus() == null) {
            ticket.setStatus(TicketStatus.PENDING);
            JsonNode forwardTo;
            try {
                forwardTo = new ObjectMapper().readTree("[]");
                ticket.setForwardedTo(forwardTo);
            } catch (JsonProcessingException e) {
                e.printStackTrace();
                throw new RuntimeException("Error creating ticket");
            }
        }
        return ticketRepository.save(ticket);
    }

    public Ticket updateForward(Long id, String forwardEmail, JsonNode forwardData) {
        Ticket ticket = getTicketById(id);
        ticket.setForwardedTo(forwardData);
        return ticketRepository.save(ticket);
    }

    public Ticket replyTicket(Long id, String reply, String email) {
        Ticket ticket = getTicketById(id);
        ticket.setStatus(TicketStatus.REPLIED);
        ticket.setDateResponded(java.time.LocalDateTime.now());
        return ticketRepository.save(ticket);
    }

    public Ticket closeTicket(Long id) {
        Ticket ticket = getTicketById(id);
        ticket.setStatus(TicketStatus.CLOSED);
        return ticketRepository.save(ticket);
    }

    public List<Ticket> getTicketsByCreatedUserId(Long id) {
        return ticketRepository.findByCreatedUserId(id);
    }

    public void deleteTicket(Long id) {
        ticketRepository.deleteById(id);
    }

    public void updateTicket(Ticket ticket) {
        ticketRepository.save(ticket);
    }
}
