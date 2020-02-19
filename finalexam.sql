/*final exam*/

/*1*/

USE master;
GO

IF  DB_ID('FinalExam') IS NOT NULL
    DROP DATABASE FinalExam;
GO

CREATE DATABASE FinalExam;
GO

use FinalExam;
go
/*2*/

create table Students
(
	studentid		int				primary key identity,
	lastname		varchar(50)		not null,
	firstname		varchar(50)		not null,
	major			varchar(50)		not null
);

create table Courses
(
	courseid		int				primary key identity,
	coursename		varchar(50)		not null,
	credits			int				not null
);

create table Registration
(
	studentid		int				references Students(studentid),
	courseid		int				references Courses(courseid),
	Grade			int				not null


primary key (CourseID, StudentID),	--Composite Primary Key

);
go

/*3*/

create proc spInsertNewStudent
	@lastname		varchar(50),
	@firstname		varchar(50),
	@major			varchar(50)
as
	
	insert into Students(lastname,firstname,major)
	values(@lastname, @firstname, @major);

/*4*/
	exec spInsertNewStudent 'Stokes','Jesse','Software Devlopment';
	exec spInsertNewStudent 'Bot','Smart','Software Development';
go

/*5*/
/*drop table Student_Audit
go*/

create table Student_Audit
(
	auditID				int				primary key identity,
	studentid			int				not null,
	lastname			varchar(50)		not null,
	firstname			varchar(50)		not null,
	major				varchar(50)		not null,
	dateUpdated			Date	default null
);
go

/*6*/
create trigger student_UPDATE
	on students
	after update, delete
as
	insert into Student_Audit(studentid, lastname,
	firstname,major, dateUpdated)
	values(
	(select studentid from deleted),
	(select lastname from deleted),
	(select firstname from deleted),
	(select major from deleted),
	GetDate());
go
 
/*7*/

drop proc spUpdateMajor;
go

create proc spUpdateMajor
	@studentid		int,
	@major			varchar(50)
as
	update Students
	set major = @major
	where studentid = 1
go
/*8*/
exec spUpdateMajor 2, 'English';
go

/*9*/
 create proc spNewCourse
	@coursename			varchar(50),
	@credits			int
as
	--validate
	if @credits <1 or @credits > 5
		throw 50001, 'The credits must be between 2 and 5',1;


	insert into Courses(coursename,credits)
	values(@coursename, @credits);

/*10*/
	exec spNewCourse 'Biology',2;
	exec spNewCourse 'Science',2;
	exec spNewCourse 'Composition',2;

	select * from courses;
go

/*11*/

drop proc spRegistration;
go

select * from Students
go

 create proc spRegistration
	@studentid			int,
	@courseid			int,
	@Grade				int
as

	insert into Registration(studentid,courseid,Grade)
	values(@studentid,@courseid,@Grade);
go
	exec spRegistration 2,3,4;--foregin key constraint
	select * from registration
go

/*12*/

exec spRegistration 1,1,4;
go
exec spRegistration 1,2,3;
go
exec spRegistration 1,3,2;
go
exec spRegistration 2,1,2;
go
exec spRegistration 2,2,4;
go
exec spRegistration 2,3,2;
go

/*13*/

create function fnGPA
(
	@studentid		int
)

returns real
begin
	declare @GPA	real;

	select @GPA =  sum(grade*credits)/cast(sum(credits)as real)
	from registration r
	join Courses c on r.courseid=c.courseid
	

	return @GPA;
end;
go

/*14*/

select studentid, lastname, firstname,dbo.fnGPA(studentid) as GPA
from Students;