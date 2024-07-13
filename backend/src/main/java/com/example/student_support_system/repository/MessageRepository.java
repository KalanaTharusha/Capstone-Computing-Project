package com.example.student_support_system.repository;
import java.util.List;
import org.springframework.stereotype.Repository;
import org.springframework.data.jpa.repository.JpaRepository;

import com.example.student_support_system.model.Message;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long>{
    List<Message> findByChannelId(Long id);
}
