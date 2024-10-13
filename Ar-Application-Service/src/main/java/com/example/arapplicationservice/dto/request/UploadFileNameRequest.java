package com.example.arapplicationservice.dto.request;

import lombok.Getter;
import lombok.Setter;
import java.util.Map;

@Getter
@Setter
public class UploadFileNameRequest {
    private String roomUniqueId;
    private Map<String,String> fileNames; // Key: markerFileName, Value: modelFileName
    @Override
    public String toString() {
        return "UploadFileNameRequest{" +
                "uniqueRoomId='" + roomUniqueId + '\'' +
                ", fileNames=" + fileNames +
                '}';
    }
}
