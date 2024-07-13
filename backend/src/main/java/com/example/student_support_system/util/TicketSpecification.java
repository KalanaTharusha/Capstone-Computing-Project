package com.example.student_support_system.util;

import java.util.ArrayList;
import java.util.List;

import org.springframework.data.jpa.domain.Specification;

import com.example.student_support_system.model.ticket.Ticket;
import com.example.student_support_system.model.ticket.TicketCategory;
import com.example.student_support_system.model.ticket.TicketStatus;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

public class TicketSpecification {
    public static Specification<Ticket> withParams(String title, String category, String status, String order, int page,
            int size) {
        return (Root<Ticket> root, CriteriaQuery<?> query, CriteriaBuilder criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (title != null && !title.equals("none") && !title.isBlank()) {
                predicates.add(criteriaBuilder.like(root.get("title"), "%" + title + "%"));
            }
            if (category != null && !category.equals("none") && !category.isBlank()) {
                predicates.add(criteriaBuilder.equal(root.get("category"), TicketCategory.valueOf(category)));
            }
            if (status != null && !status.equals("none") && !status.isBlank()) {
                predicates.add(criteriaBuilder.equal(root.get("status"), TicketStatus.valueOf(status.toUpperCase())));
            }

            if (order != null && !order.equals("none") && !order.isBlank()) {
                if (order.equals("asc")) {
                    query.orderBy(criteriaBuilder.asc(root.get("dateCreated")));
                } else if (order.equals("desc")) {
                    query.orderBy(criteriaBuilder.desc(root.get("dateCreated")));
                }
            } else {
                query.orderBy(criteriaBuilder.desc(root.get("dateCreated")));
            }

            return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
        };
    }
}
