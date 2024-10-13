package com.example.arapplicationservice.exceptions;

import org.springframework.dao.DataIntegrityViolationException;

import java.nio.file.FileAlreadyExistsException;

public class DuplicateFileExtension extends RuntimeException{
    public DuplicateFileExtension(String message, DataIntegrityViolationException cause) {
        super(message, cause);
    }
    public DuplicateFileExtension(String message, FileAlreadyExistsException cause) {
        super(message, cause);
    }
}
