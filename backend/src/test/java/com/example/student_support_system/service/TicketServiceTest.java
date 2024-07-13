package com.example.student_support_system.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.aspectj.lang.annotation.Before;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.springframework.security.core.userdetails.User;

import com.example.student_support_system.model.ticket.Ticket;
import com.example.student_support_system.model.ticket.TicketCategory;
import com.example.student_support_system.model.ticket.TicketStatus;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.model.user.UserAccountRole;
import com.example.student_support_system.model.user.UserAccountStatus;
import com.example.student_support_system.repository.TicketRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.api.client.json.Json;
import com.google.api.client.util.DateTime;

public class TicketServiceTest {

        @InjectMocks
        private TicketService ticketService;

        @Mock
        private TicketRepository ticketRepository;

        @BeforeEach
        void setUp() {
                MockitoAnnotations.openMocks(this);
        }

        @Test
        public void testGetAllTickets() {

                UserAccount userAccount = new UserAccount(
                                10L,
                                "1010",
                                "First Name",
                                "Last Name",
                                "email",
                                null, UserAccountRole.STUDENT,
                                "password",
                                UserAccountStatus.ACTIVATED);

                Ticket ticket = new Ticket(
                                1L,
                                userAccount,
                                LocalDateTime.now(),
                                LocalDateTime.now(),
                                null,
                                "title",
                                "description",
                                TicketStatus.PENDING,
                                TicketCategory.Academic);

                List<Ticket> tickets = new ArrayList<>();
                tickets.add(ticket);

                when(ticketRepository.findAll()).thenReturn(tickets);

                assertEquals(tickets, ticketService.getAllTickets());
                verify(ticketRepository, times(1)).findAll();

        }

        @Test
        public void testCreateTicket() {

                UserAccount userAccount = new UserAccount(
                                10L,
                                "1010",
                                "First Name",
                                "Last Name",
                                "email",
                                null, UserAccountRole.STUDENT,
                                "password",
                                UserAccountStatus.ACTIVATED);

                Ticket ticket = new Ticket(
                                1L,
                                userAccount,
                                LocalDateTime.now(),
                                LocalDateTime.now(),
                                null,
                                "title",
                                "description",
                                TicketStatus.PENDING,
                                TicketCategory.Academic);

                when(ticketRepository.save(ticket)).thenReturn(ticket);

                Ticket createdTicket = ticketService.createTicket(ticket);

                assertEquals(ticket, createdTicket);
                verify(ticketRepository, times(1)).save(ticket);

        }

        @Test
        public void testGetTicketsByCreatedUserId() {
                UserAccount userAccount = new UserAccount(
                                10L,
                                "1010",
                                "First Name",
                                "Last Name",
                                "email",
                                null,
                                UserAccountRole.STUDENT,
                                "password",
                                UserAccountStatus.ACTIVATED);

                Ticket userTicket = new Ticket(
                                3L,
                                userAccount,
                                LocalDateTime.now(),
                                LocalDateTime.now(),
                                null,
                                "title",
                                "description",
                                TicketStatus.PENDING,
                                TicketCategory.Sports);

                List<Ticket> userTickets = new ArrayList<>();
                userTickets.add(userTicket);

                when(ticketRepository.findByCreatedUserId(3L)).thenReturn(userTickets);

                assertEquals(userTickets, ticketService.getTicketsByCreatedUserId(3L));
                verify(ticketRepository, times(1)).findByCreatedUserId(3L);

        }

        @Test
        public void testUpdateForward() {
                try {
                        UserAccount userAccount = new UserAccount(
                                        10L,
                                        "1010",
                                        "Test first name",
                                        "Test last name",
                                        "test@test.com",
                                        null,
                                        UserAccountRole.STUDENT,
                                        "testpassword",
                                        UserAccountStatus.ACTIVATED);

                        Ticket ticket = new Ticket(
                                        1L,
                                        userAccount,
                                        LocalDateTime.now(),
                                        null,
                                        null,
                                        "title",
                                        "description",
                                        TicketStatus.PENDING,
                                        TicketCategory.Academic);

                        JsonNode forwardData = new ObjectMapper().readTree(
                                        "[{\"time\" : \"2024-04-19T12:30:45Z\", \"email\" : \"user@gmail.com\"}]");

                        when(ticketRepository.findById(1L)).thenReturn(Optional.of(ticket));
                        when(ticketRepository.save(ticket)).thenReturn(ticket);

                        Ticket updatedTicket = ticketService.updateForward(1L, userAccount.getEmailAddress(),
                                        forwardData);

                        assertEquals(forwardData, updatedTicket.getForwardedTo());
                        verify(ticketRepository, times(1)).findById(1L);
                        verify(ticketRepository, times(1)).save(ticket);

                } catch (JsonMappingException e) {
                        e.printStackTrace();
                } catch (JsonProcessingException e) {
                        e.printStackTrace();
                }

        }

        @Test
        public void testReplyTicket() {
                UserAccount userAccount = new UserAccount(
                                10L,
                                "1010",
                                "Test first name",
                                "Test last name",
                                "test@test.com",
                                null,
                                UserAccountRole.STUDENT,
                                "testpassword",
                                UserAccountStatus.ACTIVATED);

                Ticket ticket = new Ticket(
                                1L,
                                userAccount,
                                LocalDateTime.now(),
                                null,
                                null,
                                "title",
                                "description",
                                TicketStatus.PENDING,
                                TicketCategory.Academic);

                when(ticketRepository.findById(1L)).thenReturn(Optional.of(ticket));
                when(ticketRepository.save(ticket)).thenReturn(ticket);

                Ticket repliedTicket = ticketService.replyTicket(1L, "reply", "email");

                assertEquals(TicketStatus.REPLIED, repliedTicket.getStatus());
                assertNotEquals(null, repliedTicket.getDateResponded());
                verify(ticketRepository, times(1)).findById(1L);
                verify(ticketRepository, times(1)).save(ticket);

        }

        @Test
        public void testCloseTicket() {
                UserAccount userAccount = new UserAccount(
                                10L,
                                "1010",
                                "Test first name",
                                "Test last name",
                                "test@test.com",
                                null,
                                UserAccountRole.STUDENT,
                                "testpassword",
                                UserAccountStatus.ACTIVATED);

                Ticket ticket = new Ticket(
                                1L,
                                userAccount,
                                LocalDateTime.now(),
                                null,
                                null,
                                "title",
                                "description",
                                TicketStatus.PENDING,
                                TicketCategory.Academic);

                when(ticketRepository.findById(1L)).thenReturn(Optional.of(ticket));
                when(ticketRepository.save(ticket)).thenReturn(ticket);

                Ticket closedTicket = ticketService.closeTicket(1L);

                assertEquals(TicketStatus.CLOSED, closedTicket.getStatus());
                verify(ticketRepository, times(1)).findById(1L);
                verify(ticketRepository, times(1)).save(ticket);

        }

}
