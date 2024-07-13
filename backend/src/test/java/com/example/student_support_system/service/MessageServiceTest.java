package com.example.student_support_system.service;

import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentMatchers;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;

import com.example.student_support_system.dto.message.DeleteMessageDTO;
import com.example.student_support_system.dto.message.EditMessageDTO;
import com.example.student_support_system.dto.message.NewMessageDTO;
import com.example.student_support_system.model.Channel;
import com.example.student_support_system.model.Message;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.repository.ChannelRepository;
import com.example.student_support_system.repository.FcmRepository;
import com.example.student_support_system.repository.MessageRepository;
import com.example.student_support_system.repository.UserAccountRepository;
import com.google.api.services.storage.Storage.BucketAccessControls.Delete;

class MessageServiceTest {

    @InjectMocks
    private MessageService messageService;

    @Mock
    private MessageRepository messageRepository;

    @Mock
    private ChannelRepository channelRepository;

    @Mock
    private UserAccountRepository userAccountRepository;

    @Mock
    private FcmRepository fcmRepository;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    public void testCreateMessage() {

        NewMessageDTO newMessageDTO = new NewMessageDTO();
        newMessageDTO.setChannelId("1");
        newMessageDTO.setUserId("0000");
        newMessageDTO.setData("Test Message");
        newMessageDTO.setType("Text");
        newMessageDTO.setAttachmentId(null);

        Channel mockChannel = new Channel();
        mockChannel.setId(1L);
        mockChannel.setName("Test Channel");

        UserAccount mockUser1 = new UserAccount();
        mockUser1.setUserId("0000");
        mockUser1.setId(1L);

        UserAccount mockUser2 = new UserAccount();
        mockUser2.setUserId("0001");
        mockUser2.setId(2L);

        Message mockMessage = new Message();
        mockMessage.setData("Test Message");
        mockMessage.setType("Text");
        mockMessage.setChannel(mockChannel);
        mockMessage.setUser(mockUser1);

        List<UserAccount> members = new ArrayList<>();
        members.add(mockUser1);
        members.add(mockUser2);

        mockChannel.setMembers(members);

        when(channelRepository.findById(mockChannel.getId())).thenReturn(Optional.of(mockChannel));
        when(userAccountRepository.findByUserId(mockUser1.getUserId())).thenReturn(Optional.of(mockUser1));
        when(fcmRepository.findFcmTokenByUserId(ArgumentMatchers.anyLong())).thenReturn(new ArrayList<>());
        when(messageRepository.save(any(Message.class))).thenReturn(mockMessage);

        Message savedMessage = messageService.createMessage(newMessageDTO);

        assertEquals("Test Message", savedMessage.getData());
        assertEquals("Text", savedMessage.getType());
        assertEquals(mockChannel, savedMessage.getChannel());
        assertEquals(mockUser1, savedMessage.getUser());

        verify(channelRepository, times(1)).findById(1L);
        verify(userAccountRepository, times(1)).findByUserId("0000");
        verify(fcmRepository, times(mockChannel.getMembers().size() - 1))
                .findFcmTokenByUserId(ArgumentMatchers.anyLong());
        verify(messageRepository, times(1)).save(ArgumentMatchers.any(Message.class));
        verify(channelRepository, times(1)).save(ArgumentMatchers.any(Channel.class));

    }

    @Test
    public void testGetMessagesByChannelId() {

        UserAccount mockUser = new UserAccount();
        mockUser.setUserId("0000");

        Channel mockChannel = new Channel();
        mockChannel.setId(1L);
        mockChannel.setName("Test Channel");

        Message mockMessage = new Message();
        mockMessage.setData("Test Message");
        mockMessage.setType("Text");
        mockMessage.setChannel(mockChannel);
        mockMessage.setUser(mockUser);

        List<Message> messages = new ArrayList<>();
        messages.add(mockMessage);

        when(channelRepository.findById(mockChannel.getId())).thenReturn(Optional.of(mockChannel));
        when(messageRepository.findByChannelId(mockChannel.getId())).thenReturn(messages);

        List<Message> retrievedMessages = messageService.getMessagesByChannel(1L);

        assertEquals(1, retrievedMessages.size());
        assertEquals("Test Message", retrievedMessages.get(0).getData());
        assertEquals("Text", retrievedMessages.get(0).getType());
        assertEquals(mockChannel, retrievedMessages.get(0).getChannel());
        assertEquals(mockUser, retrievedMessages.get(0).getUser());

        verify(channelRepository, times(1)).findById(1L);
        verify(messageRepository, times(1)).findByChannelId(1L);
    }

    @Test
    public void testDeleteMessage() {

        DeleteMessageDTO deleteMessageDTO = new DeleteMessageDTO();
        deleteMessageDTO.setMessageId(1L);
        deleteMessageDTO.setModifiedBy("0000");

        UserAccount mockUser1 = new UserAccount();
        mockUser1.setUserId("0000");
        mockUser1.setId(1L);

        UserAccount mockUser2 = new UserAccount();
        mockUser2.setUserId("0001");
        mockUser2.setId(2L);

        ArrayList<UserAccount> members = new ArrayList<>();
        members.add(mockUser1);
        members.add(mockUser2);

        Channel mockChannel = new Channel();
        mockChannel.setId(1L);
        mockChannel.setName("Test Channel");
        mockChannel.setMembers(members);

        Message mockMessage = new Message();
        mockMessage.setId(1L);
        mockMessage.setData("Test Message");
        mockMessage.setType("Text");
        mockMessage.setChannel(mockChannel);
        mockMessage.setUser(mockUser1);

        when(channelRepository.findById(mockChannel.getId())).thenReturn(Optional.of(mockChannel));
        when(messageRepository.findById(1L)).thenReturn(Optional.of(mockMessage));
        when(fcmRepository.findFcmTokenByUserId(ArgumentMatchers.anyLong())).thenReturn(new ArrayList<>());

        Message retuenMessage = messageService.deleteMessage(deleteMessageDTO);

        assertEquals(mockMessage, retuenMessage);

        verify(messageRepository, times(1)).findById(1L);
        verify(fcmRepository, times(mockChannel.getMembers().size() - 1))
                .findFcmTokenByUserId(ArgumentMatchers.anyLong());
        verify(messageRepository, times(1)).delete(mockMessage);
    }

    @Test
    public void testEditMessage() {

        EditMessageDTO newMessageDTO = new EditMessageDTO();
        newMessageDTO.setMessageId(1L);
        newMessageDTO.setModifiedBy("0000");
        newMessageDTO.setText("Edit Data");
        newMessageDTO.setUserId("0000");

        Channel mockChannel = new Channel();
        mockChannel.setId(1L);
        mockChannel.setName("Test Channel");

        UserAccount mockUser = new UserAccount();
        mockUser.setUserId("0000");
        mockUser.setId(1L);

        UserAccount mockUser2 = new UserAccount();
        mockUser2.setUserId("0001");
        mockUser2.setId(2L);

        Message mockMessage = new Message();
        mockMessage.setData("Old data");
        mockMessage.setType("Text");
        mockMessage.setChannel(mockChannel);
        mockMessage.setUser(mockUser);

        List<UserAccount> members = new ArrayList<>();
        members.add(mockUser);
        mockChannel.setMembers(members);

        when(channelRepository.findById(mockChannel.getId())).thenReturn(Optional.of(mockChannel));
        when(userAccountRepository.findByUserId(mockUser.getUserId())).thenReturn(Optional.of(mockUser));
        when(fcmRepository.findFcmTokenByUserId(ArgumentMatchers.anyLong())).thenReturn(new ArrayList<>());
        when(messageRepository.findById(1L)).thenReturn(Optional.of(mockMessage));
        when(messageRepository.save(any(Message.class))).thenReturn(mockMessage);

        Message savedMessage = messageService.editMessage(newMessageDTO);

        assertEquals("Edit Data", savedMessage.getData());

        verify(fcmRepository, times(mockChannel.getMembers().size() - 1))
                .findFcmTokenByUserId(ArgumentMatchers.anyLong());
        verify(messageRepository, times(1)).findById(1L);
        verify(messageRepository, times(1)).save(ArgumentMatchers.any(Message.class));
    }
}
