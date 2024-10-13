package com.example.arapplicationservice.dto.response;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class IOSResponse {
    private List<String> markers;
    private List<String> models;
}