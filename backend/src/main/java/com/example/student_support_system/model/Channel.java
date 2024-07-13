package com.example.student_support_system.model;

import java.util.List;

import com.example.student_support_system.model.user.UserAccount;
import com.google.auto.value.AutoValue.Builder;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class Channel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String name;

    @Column
    private String description;

    @ManyToMany
    @JoinTable(name = "channel_members", inverseJoinColumns = @JoinColumn(name = "user_id", referencedColumnName = "id"))
    private List<UserAccount> members;

    @ManyToMany
    @JoinTable(name = "channel_admins", inverseJoinColumns = @JoinColumn(name = "user_id", referencedColumnName = "id"))
    private List<UserAccount> admins;

    @Column
    private String category;

    @Column
    private Long lastMessageId;
}
