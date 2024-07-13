package com.example.student_support_system.repository;

import com.example.student_support_system.model.Announcement;
import com.example.student_support_system.model.AnnouncementCategory;
import org.checkerframework.checker.units.qual.A;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.awt.print.Pageable;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AnnouncementRepository extends JpaRepository<Announcement, Long> {
    List<Announcement> findAnnouncementsByCreateDateBetween(LocalDateTime startDate, LocalDateTime endDate);
    List<Announcement> findAllByTitleContainingIgnoreCase(String term, PageRequest pageRequest);
    List<Announcement> findAnnouncementsByCategoryOrderByUpdateDateDesc(AnnouncementCategory category);
}
