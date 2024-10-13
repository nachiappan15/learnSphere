package com.example.arapplicationservice.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name="file_path")
public class Filepath {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name="reference_room_key",referencedColumnName = "id")
    private Room roomData;

    @Column(name = "marker_file_path")
    private String markerFilePath;

    @Column(name = "model_file_path")
    private String modelFilePath;

}
