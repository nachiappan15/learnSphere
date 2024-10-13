create table room(
id serial primary key,
room_key varchar(100) not null
);

create table file_path(
id serial primary key,
reference_room_key int not null,
marker_file_path varchar not null,
model_file_path varchar not null,
constraint fk_room_room_key foreign key(reference_room_key) references room(id)
);

insert into room(room_key) values ('1234');

select * from room;
select * from file_path;

select fp.marker_file_path,fp.model_file_path from file_path fp
join room r on r.id = fp.reference_room_key
where r.room_key='1234';