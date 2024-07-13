package com.example.student_support_system.controller;

import java.util.Collections;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import com.example.student_support_system.dto.channel.ChannelSubscribeDTO;
import com.example.student_support_system.dto.channel.CreateChannelDTO;
import com.example.student_support_system.dto.channel.UpdateChannelDTO;
import com.example.student_support_system.model.Channel;
import com.example.student_support_system.service.ChannelService;

@ExtendWith(MockitoExtension.class)
public class ChannelControllerTest {

    @Mock
    private ChannelService channelService;

    @InjectMocks
    private ChannelController channelController;

    @Test
    void testGetAllChannels() {
        try {
            Channel channel = new Channel();
            Mockito.when(channelService.getAllChannels()).thenReturn(Collections.singletonList(channel));

            ResponseEntity responseEntity = channelController.getAllChannels();

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("getAllChannelsTest failed", exception);
        }
    }

    @Test
    void testGetChannelById() {
        try {
            Channel channel = new Channel();
            Mockito.when(channelService.getChannelById(1L)).thenReturn(channel);

            ResponseEntity responseEntity = channelController.getChannelById(1L);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("getChannelByIdTest failed", exception);
        }
    }

    @Test
    void testGetChannelsByCategory() {
        try {
            Channel channel = new Channel();
            Mockito.when(channelService.getChannelsByCategory("ACADEMIC"))
                    .thenReturn(Collections.singletonList(channel));

            ResponseEntity responseEntity = channelController.getChannelsByCategory("ACADEMIC");

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("getChannelsByCategoryTest failed", exception);
        }
    }

    @Test
    void testGetChannelsByUser() {
        try {
            Channel channel = new Channel();
            Mockito.when(channelService.getChannelsByUser("0000"))
                    .thenReturn(Collections.singletonList(channel));

            ResponseEntity responseEntity = channelController.getChannelsByUser("0000");

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("getChannelsByUserTest failed", exception);
        }
    }

    @Test
    void testGetChannelsToSubscribe() {
        try {
            Channel channel = new Channel();
            Mockito.when(channelService.getChannelsToSubscribe("0000"))
                    .thenReturn(Collections.singletonList(channel));

            ResponseEntity responseEntity = channelController.getChannelsToSubscribe("0000");

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("getChannelsToSubscribeTest failed", exception);
        }
    }

    @Test
    void testCreateChannel() {
        try {
            Channel channel = new Channel();
            CreateChannelDTO createChannelDto = new CreateChannelDTO();
            Mockito.when(channelService.createChannel(createChannelDto)).thenReturn(channel);

            ResponseEntity responseEntity = channelController.createChannel(createChannelDto);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("createChannelTest failed", exception);
        }
    }

    @Test
    void testUpdateChannel() {
        try {
            Channel channel = new Channel();
            UpdateChannelDTO updateChannelDto = new UpdateChannelDTO();
            Mockito.when(channelService.updateChannel(updateChannelDto)).thenReturn(channel);

            ResponseEntity responseEntity = channelController.updateChannel(updateChannelDto);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertNotNull(responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("updateChannelTest failed", exception);
        }
    }

    @Test
    void testDeleteChannel() {
        try {
            Channel channel = new Channel();
            Mockito.when(channelService.deleteChannel(1L)).thenReturn(channel);

            ResponseEntity responseEntity = channelController.deleteChannel(1L);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertEquals("Channel deleted",
                    responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("deleteChannelTest failed", exception);
        }
    }

    @Test
    void testSubscribeToChannel() {
        try {
            ChannelSubscribeDTO channelSubscribeDto = new ChannelSubscribeDTO(1L, "0000");
            Mockito.doNothing().when(channelService).subscribeUserToChannel(channelSubscribeDto.getChannelId(),
                    channelSubscribeDto.getUserId());

            ResponseEntity responseEntity = channelController.subscribeUserToChannel(channelSubscribeDto);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertEquals("User subscribed to channel", responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("subscribeToChannelTest failed", exception);
        }
    }

    @Test
    void testUnsubscribeFromChannel() {
        try {
            ChannelSubscribeDTO channelSubscribeDto = new ChannelSubscribeDTO(1L, "0000");
            Mockito.doNothing().when(channelService).unsubscribeUserFromChannel(channelSubscribeDto.getChannelId(),
                    channelSubscribeDto.getUserId());

            ResponseEntity responseEntity = channelController.unsubscribeUserFromChannel(channelSubscribeDto);

            Assertions.assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
            Assertions.assertEquals("User unsubscribed from channel", responseEntity.getBody());
        } catch (Exception exception) {
            Assertions.fail("unsubscribeFromChannelTest failed", exception);
        }
    }

}
