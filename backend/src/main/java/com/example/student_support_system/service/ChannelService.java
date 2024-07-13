package com.example.student_support_system.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.CrossOrigin;

import com.example.student_support_system.dto.channel.CreateChannelDTO;
import com.example.student_support_system.dto.channel.UpdateChannelDTO;
import com.example.student_support_system.exception.EntityNotFoundException;
import com.example.student_support_system.model.Channel;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.repository.ChannelRepository;
import com.example.student_support_system.repository.UserAccountRepository;

@CrossOrigin(origins = "*")
@Service
public class ChannelService {

    private ChannelRepository channelRepository;
    private UserAccountRepository userAccountRepository;

    public ChannelService(ChannelRepository channelRepository, UserAccountRepository userAccountRepository) {
        this.channelRepository = channelRepository;
        this.userAccountRepository = userAccountRepository;
    }

    public List<Channel> getAllChannels() {
        return channelRepository.findAll();
    }

    public Channel getChannelById(Long id) {
        return channelRepository.findById(id).orElseThrow();
    }

    public List<Channel> getChannelsByCategory(String category) {
        return channelRepository.findByCategory(category);
    }

    public List<Channel> getChannelsByUser(String userId) {
        return channelRepository.findByMembersUserIdContaining(userId);
    }

    public List<Channel> getChannelsToSubscribe(String userId) {
        Optional<UserAccount> optionalUser = userAccountRepository.findByUserId(userId);
        UserAccount user = unwrapUser(optionalUser, userId);
        return channelRepository.findByMembersNotContaining(user);
    }

    public Channel createChannel(CreateChannelDTO createChannelDTO) {
        List<UserAccount> members = new ArrayList<UserAccount>();

        for (String userId : createChannelDTO.getAdmins()) {
            Optional<UserAccount> optionalUser = userAccountRepository.findByUserId(userId);
            UserAccount user = unwrapUser(optionalUser, userId);
            members.add(user);
        }

        Channel channel = new Channel(
                null, createChannelDTO.getName(),
                createChannelDTO.getDescription(),
                members,
                members,
                createChannelDTO.getCategory(),
                null);

        return channelRepository.save(channel);
    }

    public Channel updateChannel(UpdateChannelDTO updateChannelDTO) {

        Optional<Channel> optionalChannel = channelRepository.findById(Long.parseLong(updateChannelDTO.getId()));
        Channel channel = unwrapChannel(optionalChannel, Long.parseLong(updateChannelDTO.getId()));

        List<UserAccount> admins = new ArrayList<UserAccount>();

        for (String userId : updateChannelDTO.getAdmins()) {
            Optional<UserAccount> optionalUser = userAccountRepository.findByUserId(userId);
            UserAccount user = unwrapUser(optionalUser, userId);
            admins.add(user);
        }

        List<UserAccount> members = new ArrayList<UserAccount>();

        for (String userId : updateChannelDTO.getMembers()) {
            Optional<UserAccount> optionalUser = userAccountRepository.findByUserId(userId);
            UserAccount user = unwrapUser(optionalUser, userId);
            members.add(user);
        }

        if (updateChannelDTO.getName() != null && updateChannelDTO.getName() != ""
                && !updateChannelDTO.getName().equals(channel.getName())) {
            channel.setName(updateChannelDTO.getName());
        }

        if (updateChannelDTO.getDescription() != null
                && !updateChannelDTO.getDescription().equals(channel.getDescription())) {
            channel.setDescription(updateChannelDTO.getDescription());
        }

        if (updateChannelDTO.getCategory() != null && updateChannelDTO.getCategory() != ""
                && !updateChannelDTO.getCategory().equals(channel.getCategory())) {
            channel.setCategory(updateChannelDTO.getCategory());
        }

        if (updateChannelDTO.getAdmins() != null && !updateChannelDTO.getAdmins().equals(channel.getAdmins())) {
            channel.setAdmins(admins);
        }

        if (updateChannelDTO.getMembers() != null && !updateChannelDTO.getMembers().equals(channel.getMembers())) {
            channel.setMembers(members);
        }

        return channelRepository.save(channel);
    }

    public Channel deleteChannel(Long id) {
        Optional<Channel> optionalChannel = channelRepository.findById(id);
        Channel channel = unwrapChannel(optionalChannel, id);
        channelRepository.delete(channel);
        return channel;
    }

    public void subscribeUserToChannel(Long channelId, String userId) {
        Optional<UserAccount> optionalUser = userAccountRepository.findByUserId(userId);
        UserAccount user = unwrapUser(optionalUser, userId);

        Optional<Channel> optionalChannel = channelRepository.findById(channelId);
        Channel channel = unwrapChannel(optionalChannel, channelId);

        if (channel.getMembers().contains(user)) {
            throw new IllegalArgumentException("User is already subscribed to this channel"); // replace with custom //
                                                                                              // exception
        }

        channelRepository.addUserToChannel(channel, user);
    }

    public void unsubscribeUserFromChannel(Long channelId, String userId) {
        Optional<UserAccount> optionalUser = userAccountRepository.findByUserId(userId);
        UserAccount user = unwrapUser(optionalUser, userId);

        Optional<Channel> optionalChannel = channelRepository.findById(channelId);
        Channel channel = unwrapChannel(optionalChannel, channelId);

        if (!channel.getMembers().contains(user)) {
            throw new IllegalArgumentException("User is not subscribed to this channel"); // replace with custom
                                                                                          // exception
        }

        channelRepository.removeUserFromChannel(channel, user);
    }

    static UserAccount unwrapUser(Optional<UserAccount> entity, String id) {
        if (entity.isPresent())
            return entity.get();
        else
            throw new EntityNotFoundException(id, UserAccount.class);
    }

    static Channel unwrapChannel(Optional<Channel> entity, Long id) {
        if (entity.isPresent())
            return entity.get();
        else
            throw new EntityNotFoundException(id.toString(), Channel.class);
    }

}
