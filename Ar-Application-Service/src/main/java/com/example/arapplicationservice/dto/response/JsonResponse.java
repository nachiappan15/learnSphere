package com.example.arapplicationservice.dto.response;

import lombok.Getter;
import lombok.Setter;

import java.util.Map;
@Getter
@Setter
public class JsonResponse {
    private Map<String,String> fileNames;
}