create user olifantys createdb password 'olifantys'; -- <a>
create database olifantysbank owner olifantys; -- <b>
create role teller login password 'teller'; -- <c>
