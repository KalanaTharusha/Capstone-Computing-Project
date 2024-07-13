package com.example.student_support_system.controller;

import com.example.student_support_system.brevo.templates.ForwardTicketTemplate;
import com.example.student_support_system.brevo.templates.OnboardingTemplate;
import com.example.student_support_system.brevo.templates.ReplyTicketTemplate;
import com.example.student_support_system.brevo.templates.TicketClosedTemplate;
import com.example.student_support_system.brevo.templates.TicketConfirmationTemplate;
import com.example.student_support_system.dto.ticket.CreateTicketRequestDTO;
import com.example.student_support_system.dto.ticket.ForwardTicketDto;
import com.example.student_support_system.dto.ticket.ReplyTicketDto;
import com.example.student_support_system.dto.ticket.UpdateTicketRequestDTO;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.model.ticket.Ticket;
import com.example.student_support_system.model.ticket.TicketCategory;
import com.example.student_support_system.service.EmailNotificationService;
import com.example.student_support_system.service.TicketService;
import com.example.student_support_system.service.UserAccountService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@RestController
@RequestMapping("/api/tickets")
public class TicketController {

    private final TicketService ticketService;

    private final UserAccountService userAccountService;

    private final EmailNotificationService emailNotificationService;

    public TicketController(
            TicketService ticketService,
            UserAccountService userAccountService,
            EmailNotificationService emailNotificationService) {
        this.ticketService = ticketService;
        this.userAccountService = userAccountService;
        this.emailNotificationService = emailNotificationService;
    }

    @GetMapping
    public ResponseEntity getAllTickets() throws Exception {
        try {
            return ResponseEntity
                    .ok()
                    .body(ticketService.getAllTickets());
        } catch (Exception exception) {
            exception.printStackTrace();
            throw new Exception(exception.getMessage());
        }
    }

    @GetMapping("/search")
    public ResponseEntity searchTickets(@RequestParam String term, @RequestParam String status,
            @RequestParam String category,
            @RequestParam String order, @RequestParam int pageNo, @RequestParam int pageSize) throws Exception {
        try {
            return ResponseEntity
                    .ok()
                    .body(ticketService.searchTickets(term, status, category, order, pageNo, pageSize));
        } catch (Exception exception) {
            exception.printStackTrace();
            throw new Exception(exception.getMessage());
        }
    }

    @GetMapping("/user/{createdUserId}")
    public ResponseEntity getTicketsByCreatedUserId(@PathVariable String createdUserId) throws Exception {
        try {
            if (createdUserId != null) {
                UserAccount createdUser = userAccountService.getUserAccountByUserId(createdUserId);
                return ResponseEntity
                        .ok()
                        .body(ticketService.getTicketsByCreatedUserId(createdUser.getId()));
            }

            return ResponseEntity
                    .ok()
                    .body(ticketService.getAllTickets());
        } catch (Exception exception) {
            exception.printStackTrace();
            throw new Exception(exception.getMessage());
        }
    }

    @PostMapping
    public ResponseEntity createTicket(
            @RequestBody CreateTicketRequestDTO createTicketRequestDTO) throws Exception {
        try {
            Ticket ticket = new Ticket();
            ticket.setTitle(createTicketRequestDTO.getTitle());
            ticket.setDescription(createTicketRequestDTO.getDescription());
            ticket.setCategory(createTicketRequestDTO.getCategory());
            UserAccount createdUser = userAccountService
                    .getUserAccountByUserId(createTicketRequestDTO.getCreatedUserId());
            ticket.setCreatedUser(createdUser);
            ticket.setDateCreated(java.time.LocalDateTime.now());

            Ticket createdTicket = ticketService.createTicket(ticket);

            emailNotificationService.sendEmailNotification(
                    new TicketConfirmationTemplate(createdUser.getFirstName(), createdTicket.getId().toString()),
                    createdUser.getEmailAddress());

            return ResponseEntity
                    .ok(createdTicket);
        } catch (Exception exception) {
            exception.printStackTrace();
            throw new Exception(exception.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity getTicketById(@PathVariable(value = "id") Long id) throws Exception {
        try {
            Ticket ticket = ticketService.getTicketById(id);

            return ResponseEntity
                    .ok()
                    .body(ticket);
        } catch (Exception exception) {
            exception.printStackTrace();
            throw new Exception(exception.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity deleteTicket(@PathVariable(value = "id") Long id) throws Exception {
        try {
            ticketService.deleteTicket(id);
            return ResponseEntity
                    .ok()
                    .body("Ticket deleted successfully");
        } catch (Exception exception) {
            exception.printStackTrace();
            throw new Exception(exception.getMessage());
        }
    }

    @PatchMapping("/{id}")
    public ResponseEntity updateTicket(
            @PathVariable(value = "id") Long existingTicketId,
            @RequestBody UpdateTicketRequestDTO updateTicketRequestDTO) throws Exception {
        try {
            Ticket existingTicket = ticketService.getTicketById(existingTicketId);

            existingTicket.setStatus(updateTicketRequestDTO.getStatus());
            existingTicket.setDateResponded(updateTicketRequestDTO.getDateResponded());
            ticketService.updateTicket(existingTicket);

            Ticket updatedTicket = ticketService.getTicketById(existingTicket.getId());

            return ResponseEntity
                    .ok()
                    .body(updatedTicket);
        } catch (Exception exception) {
            exception.printStackTrace();
            throw new Exception(exception.getMessage());
        }
    }

    @PatchMapping("/forward/{id}")
    public ResponseEntity forwardTicket(
            @PathVariable(value = "id") Long existingTicketId,
            @RequestBody ForwardTicketDto forwardTicketDto) throws Exception {
        try {
            Ticket updatedTicket = ticketService.updateForward(existingTicketId, forwardTicketDto.getForwardEmail(),
                    forwardTicketDto.getForwardData());

            emailNotificationService.sendEmailNotification(new ForwardTicketTemplate(updatedTicket.getId().toString(), forwardTicketDto.getForwardUserFirstName(), updatedTicket.getCreatedUser().getFirstName(),updatedTicket.getCreatedUser().getLastName(),updatedTicket.getCreatedUser().getEmailAddress(),updatedTicket.getDescription()), forwardTicketDto.getForwardEmail());

            return ResponseEntity
                    .ok()
                    .body(updatedTicket);
        } catch (Exception exception) {
            exception.printStackTrace();
            throw new Exception(exception.getMessage());
        }
    }

    @PatchMapping("/reply/{id}")
    public ResponseEntity replyTicket(
            @PathVariable(value = "id") Long existingTicketId,
            @RequestBody ReplyTicketDto replyTicketDto) throws Exception {
        try {
            Ticket updatedTicket = ticketService.replyTicket(existingTicketId, replyTicketDto.getReply(),
                    replyTicketDto.getEmail());

            emailNotificationService.sendEmailNotification(new ReplyTicketTemplate(updatedTicket.getId().toString(),
                    updatedTicket.getCreatedUser().getFirstName(),updatedTicket.getDescription(), replyTicketDto.getReply()),
                    updatedTicket.getCreatedUser().getEmailAddress());

            return ResponseEntity
                    .ok()
                    .body(updatedTicket);
        } catch (Exception exception) {
            exception.printStackTrace();
            throw new Exception(exception.getMessage());
        }
    }

    @PatchMapping("/close/{id}")
    public ResponseEntity closeTicket(@PathVariable(value = "id") Long existingTicketId) throws Exception {
        try {

            Ticket updatedTicket = ticketService.closeTicket(existingTicketId);

            emailNotificationService.sendEmailNotification(new TicketClosedTemplate(updatedTicket.getId().toString(),
                    updatedTicket.getCreatedUser().getFirstName(), updatedTicket.getCreatedUser().getFirstName(),updatedTicket.getCreatedUser().getLastName(),
                    updatedTicket.getCreatedUser().getEmailAddress(), updatedTicket.getDescription()),
                    updatedTicket.getCreatedUser().getEmailAddress());

            return ResponseEntity
                    .ok()
                    .body(updatedTicket);
        } catch (Exception exception) {
            exception.printStackTrace();
            throw new Exception(exception.getMessage());
        }
    }

    @GetMapping("/categories")
    public ResponseEntity getAllCategories() {
        TicketCategory[] ticketCategories = TicketCategory.class.getEnumConstants();

        return ResponseEntity
                .ok()
                .body(ticketCategories);
    }

    @GetMapping("/stats")
    public ResponseEntity getTicketStats() {
        return ResponseEntity
                .ok()
                .body(ticketService.getTicketStats());
    }

}
