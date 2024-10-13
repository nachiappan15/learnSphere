package com.example.arapplicationservice.handlers;

import com.example.arapplicationservice.exceptions.DuplicateFileExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalErrorHandlers {
    @ExceptionHandler(DuplicateFileExtension.class)
    public ResponseEntity<String> handleDuplicateFileException(DuplicateFileExtension e){
        return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage()); // Return a 409 Conflict for duplicate file (either in DB or file system)
    }
    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleGenericException(Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred=="+e.getMessage());  // Return 500 Internal Server Error for generic issues
    }
}