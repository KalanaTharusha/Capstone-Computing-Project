package com.example.student_support_system.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.student_support_system.model.Channel;
import com.example.student_support_system.model.user.UserAccount;

@Repository
public interface ChannelRepository extends JpaRepository<Channel, Long>{

        Optional<Channel> findById(Long id);

    Channel findByName(String name);

    List<Channel> findByMembersUserIdContaining(String userId);

    List<Channel> findByMembersUserIdNotContaining(String userId);

    List<Channel> findByCategoryAndMembersNotContaining(String category, UserAccount user);

    List<Channel> findByMembersNotContaining(UserAccount user);
    
    List<Channel> findByCategory(String category);

    default void addUserToChannel(Channel channel, UserAccount newMember) {
            List<UserAccount> currentMembers = channel.getMembers();
            currentMembers.add(newMember);
            channel.setMembers(currentMembers);
            save(channel);
    }

    default void removeUserFromChannel(Channel channel, UserAccount memberToRemove) {
            List<UserAccount> currentMembers = channel.getMembers();
            currentMembers.remove(memberToRemove);
            channel.setMembers(currentMembers);
            save(channel);
    }
}
