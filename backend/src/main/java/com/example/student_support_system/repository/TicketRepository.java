package com.example.student_support_system.repository;

import com.example.student_support_system.model.ticket.Ticket;
import com.example.student_support_system.model.ticket.TicketCategory;
import com.example.student_support_system.model.ticket.TicketStatus;

import org.springframework.data.domain.Example;
import org.springframework.data.domain.ExampleMatcher;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, Long>, JpaSpecificationExecutor<Ticket> {

    @Query("SELECT t FROM Ticket t WHERE t.createdUser.id = ?1 ORDER BY t.dateCreated DESC")
    List<Ticket> findByCreatedUserId(Long id);

    @Query("SELECT COUNT(t) FROM Ticket t WHERE t.status = ?1")
    int countByStatus(TicketStatus status);

}
