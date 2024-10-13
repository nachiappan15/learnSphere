package com.example.arapplicationservice.endpoints;

import com.example.arapplicationservice.dto.response.IOSResponse;
import com.example.arapplicationservice.dto.response.JsonResponse;
import com.example.arapplicationservice.service.FilesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
public class FilesEndpoint {

    @Autowired
    private FilesService filesService;

    @PostMapping("/upload")
    public String saveFile(@RequestParam("jsonData") String jsonData, @RequestParam("file") MultipartFile[] files) {
        filesService.uploadFileService(jsonData,files);
        return "uploaded";
    }
    @GetMapping("/files/{filename}")
    public ResponseEntity<Resource> serveFile(@PathVariable String filename) {
        return filesService.downloadFileService(filename);
    }
    @GetMapping("/get/{roomId}")
    public JsonResponse getFileNames(@PathVariable String roomId){
        return filesService.getFileNames(roomId);
    }
    @GetMapping("/ios/{roomId}")
    public IOSResponse getFileNamesIOS(@PathVariable String roomId){
        return filesService.getFileNamesIOS(roomId);
    }
}