package com.example.student_support_system.controller;

import org.springframework.web.bind.annotation.*;

import com.example.student_support_system.dto.channel.ChannelSubscribeDTO;
import com.example.student_support_system.dto.channel.CreateChannelDTO;
import com.example.student_support_system.dto.channel.UpdateChannelDTO;
import com.example.student_support_system.model.Channel;
import com.example.student_support_system.service.ChannelService;
import com.example.student_support_system.util.ApiUtil;
import com.example.student_support_system.util.logging.AppLogger;
import com.google.api.services.storage.Storage.BucketAccessControls.Update;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;


@CrossOrigin(origins = "*", allowedHeaders = "*")
@RestController
@RequestMapping(value = "/api/channels", produces = "application/json")
public class ChannelController {
    
    private final ChannelService channelService;

    public ChannelController(ChannelService channelService) {
        this.channelService = channelService;
    }

    //GET channels to subscribe by category (To be implemented)

    @GetMapping()
    public ResponseEntity getAllChannels() {
        try {
            return ResponseEntity
                    .ok()
                    .body(channelService.getAllChannels());
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @GetMapping("/id/{id}")
    public ResponseEntity getChannelById(@PathVariable Long id) {
        try {
            return ResponseEntity
                    .ok()
                    .body(channelService.getChannelById(id));
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @GetMapping("/category/{category}")
    public ResponseEntity getChannelsByCategory(@PathVariable String category) {
        try {
            return ResponseEntity
                    .ok()
                    .body(channelService.getChannelsByCategory(category));
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @GetMapping("/subscribed/{userId}")
    public ResponseEntity getChannelsByUser(@PathVariable String userId) {
        try {
            return ResponseEntity
                    .ok()
                    .body(channelService.getChannelsByUser(userId));
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }


    @GetMapping("/toSubscribe")
    public ResponseEntity getChannelsToSubscribe( @RequestHeader("userId") String userId) {

        try {
            return ResponseEntity
                    .ok()
                    .body(channelService.getChannelsToSubscribe(userId));
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }
    

    @PostMapping("/create")
    public ResponseEntity createChannel(@RequestBody @Validated CreateChannelDTO createChannelDto) {
        try {
            Channel createdChannel = channelService.createChannel(createChannelDto);

            return ResponseEntity
                    .ok()
                    .body(createdChannel);
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }
    
    @PutMapping("/update")
    public ResponseEntity updateChannel(@RequestBody @Validated UpdateChannelDTO updateChannelDTO) {
        try {
            Channel createdChannel = channelService.updateChannel(updateChannelDTO);

            return ResponseEntity
                    .ok()
                    .body(createdChannel);
        }
        catch (Exception exception) {
            AppLogger.error(exception.toString());
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity deleteChannel(@PathVariable Long id) {
        try {
            channelService.deleteChannel(id);

            return ResponseEntity
                    .ok()
                    .body("Channel deleted");
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }
    

    @PostMapping("/subscribe")
    public ResponseEntity subscribeUserToChannel(@RequestBody @Validated ChannelSubscribeDTO channelSubscribeDto) {
        try {

            channelService.subscribeUserToChannel(channelSubscribeDto.getChannelId(), channelSubscribeDto.getUserId());

            return ResponseEntity
                    .ok()
                    .body("User subscribed to channel");
        }
        catch (Exception exception) {
            System.err.println(exception);
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }

    @PostMapping("/unsubscribe")
    public ResponseEntity unsubscribeUserFromChannel(@RequestBody @Validated ChannelSubscribeDTO channelSubscribeDto) {
        try {

            channelService.unsubscribeUserFromChannel(channelSubscribeDto.getChannelId(), channelSubscribeDto.getUserId());

            return ResponseEntity
                    .ok()
                    .body("User unsubscribed from channel");
        }
        catch (Exception exception) {
            return ResponseEntity
                    .internalServerError()
                    .body(exception.getMessage());
        }
    }
}
