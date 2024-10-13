package com.example.arapplicationservice.repository;

import com.example.arapplicationservice.domain.Filepath;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface FilepathRepository extends JpaRepository<Filepath,Integer> {
    @Query("SELECT fp FROM Filepath fp " +
            "JOIN fp.roomData r ON r.id = fp.roomData.id " +
            "WHERE r.roomUniqueId = :roomKey")
    List<Filepath> findAllByRoomId(@Param("roomKey") String roomId);
}
