package com.example.student_support_system.dto.channel;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChannelSubscribeDTO {
    private Long channelId;
    private String userId;
}
