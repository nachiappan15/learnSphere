package com.example.arapplicationservice.service;

import com.example.arapplicationservice.domain.Filepath;
import com.example.arapplicationservice.dto.request.UploadFileNameRequest;
import com.example.arapplicationservice.dto.response.IOSResponse;
import com.example.arapplicationservice.dto.response.JsonResponse;
import com.example.arapplicationservice.exceptions.DuplicateFileExtension;
import com.example.arapplicationservice.repository.FilepathRepository;
import com.example.arapplicationservice.repository.RoomRepository;
import com.example.arapplicationservice.domain.Room;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class FilesService {
    @Autowired
    RoomRepository roomRepository;

    @Autowired
    FilepathRepository filepathRepository;

    @Value("${file.uploadMarker-dir}")
    private String fileUploadMarkerDir;

    @Value("${file.uploadModel-dir}")
    private String fileUploadModelDir;

    public ResponseEntity<Resource> downloadFileService(String filename) {
        try{
            Path fileDirPath ;
            if (filename.endsWith(".zip") || filename.endsWith(".usdz") ) {
                fileDirPath = Paths.get(fileUploadModelDir).resolve(filename);
            } else {
                fileDirPath = Paths.get(fileUploadMarkerDir).resolve(filename);
            }
                Resource resource = new UrlResource(fileDirPath.toUri());
                if (!resource.exists()) {
                    return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
                }
                HttpHeaders headers = new HttpHeaders();
                headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"");
                return ResponseEntity.ok()
                        .headers(headers)
                        .body(resource);


        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    @Transactional
    public void uploadFileService(String jsonData, MultipartFile[] files) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            UploadFileNameRequest request = objectMapper.readValue(jsonData, UploadFileNameRequest.class);

            System.out.println("uploadJSON Details: "+ request.toString());

            Room room = roomRepository.findByRoomUniqueId(request.getRoomUniqueId())
                    .orElseGet(() -> {
                Room newRoom = new Room();
                newRoom.setRoomUniqueId(request.getRoomUniqueId());
                return roomRepository.save(newRoom);
            });

            for(Map.Entry<String,String> fileNameItem : request.getFileNames().entrySet()){
                Filepath filepath = new Filepath();
                filepath.setMarkerFilePath(fileNameItem.getKey());
                filepath.setModelFilePath(fileNameItem.getValue());
                filepath.setRoomData(room);
                try {
                    filepathRepository.save(filepath);
                } catch (DataIntegrityViolationException e) { // This may throw DataIntegrityViolationException if duplicates exist
                    throw new DuplicateFileExtension("Duplicate marker or model file path: "+ e.getMessage(), e);
                }
            }
            for (MultipartFile file : files) {
                String filename = file.getOriginalFilename();
                Path fileDirPath;
                assert filename != null; //checking file name is null or not.
                if (filename.endsWith(".zip") || filename.endsWith(".usdz")) {
                    fileDirPath = Paths.get(fileUploadModelDir).resolve(filename);
                } else {
                    fileDirPath = Paths.get(fileUploadMarkerDir).resolve(filename);
                }
                if (Files.exists(fileDirPath)) {
                    throw new FileAlreadyExistsException("File " + filename + " already exists.");
                }
                Files.copy(file.getInputStream(), fileDirPath);
//            Files.copy(file.getInputStream(), fileDirPath, StandardCopyOption.REPLACE_EXISTING); //for replacing the existing file.
            }
        }
        catch (FileAlreadyExistsException e) {
            throw new DuplicateFileExtension("FileAlreadyExistsException:-->> "+e.getMessage(), e);
        }
        catch (IOException e) {
            throw new RuntimeException("Failed to upload file: " + e.getMessage(), e);
        }
    }
    public JsonResponse getFileNames(String roomId) {
        List<Filepath> fileNames = filepathRepository.findAllByRoomId(roomId);
        JsonResponse jsonResponse = new JsonResponse();
        Map<String,String> map = new HashMap<>();
        for(Filepath filename:fileNames){
            map.put(filename.getMarkerFilePath(),filename.getModelFilePath());
        }
        jsonResponse.setFileNames(map);
        return jsonResponse;
    }

    public IOSResponse getFileNamesIOS(String roomId) {
        List<Filepath> fileNames = filepathRepository.findAllByRoomId(roomId);
        IOSResponse iosResponse = new IOSResponse();
        List<String> listmarker = new ArrayList<>();
        List<String> listmodel = new ArrayList<>();
        for(Filepath filename:fileNames){
            listmarker.add(filename.getMarkerFilePath());
            listmodel.add(filename.getModelFilePath());
        }
        iosResponse.setMarkers(listmarker);
        iosResponse.setModels(listmodel);
        return iosResponse;
    }
}
