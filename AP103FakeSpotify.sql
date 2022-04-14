CREATE DATABASE AP103Spotify

USE AP103Spotify

CREATE TABLE Artists(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE Albums(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(100) NOT NULL,
	ReleaseDate DATETIME2 DEFAULT GETDATE(),
	ArtistId INT FOREIGN KEY REFERENCES Artists(Id)
)

CREATE TABLE Musics(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(100) NOT NULL,
	Duration INT NOT NULL,
	ListenerCount INT DEFAULT 0,
	AlbumId INT FOREIGN KEY REFERENCES Albums(Id)
)

CREATE TABLE ArtistMusics(
	Id INT PRIMARY KEY IDENTITY,
	ArtistId INT FOREIGN KEY REFERENCES Artists(Id),
	MusicId INT FOREIGN KEY REFERENCES Musics(Id)
)

CREATE VIEW v_GetMusicInfo
AS
SELECT M.Name 'MusicName', M.Duration,
	   A.Name 'ArtistName', AL.Name 'AlbumName'
FROM Musics AS M
JOIN ArtistMusics AS MA
ON M.Id = MA.MusicId
JOIN Artists AS A
ON A.Id = MA.ArtistId
JOIN Albums AS AL
ON AL.Id = M.AlbumId

SELECT * FROM v_GetMusicInfo
WHERE Duration > 100

CREATE VIEW v_GetAlbumInfo
AS
SELECT AL.Name 'AlbumName',
       COUNT(M.Id) 'MusicCount'
FROM Musics AS M
JOIN Albums AS AL
ON M.AlbumId = AL.Id
GROUP BY AL.Name

SELECT * FROM v_GetAlbumInfo

CREATE PROCEDURE usp_SearchMusic @count INT, @search NVARCHAR(100)
AS
SELECT M.Name 'MusicName', 
       M.ListenerCount,
	   AL.Name 'AlbumName'
FROM Musics AS M
JOIN Albums AS AL
ON AL.Id = M.AlbumId
WHERE M.ListenerCount > @count AND AL.Name LIKE '%' + @search + '%'

EXEC usp_SearchMusic 60, 'te'
--EXEC usp_SearchMusic @search = 'te', @count = 60

--CREATE TABLE Settings(
--	Id INT PRIMARY KEY IDENTITY,
--	[Key] NVARCHAR(150) NOT NULL,
--	[Value] NVARCHAR(150) NOT NULL
--)

CREATE TABLE Students(
	Id INT PRIMARY KEY IDENTITY,
	Fullname NVARCHAR(100),
	IsDeleted BIT DEFAULT 'false'
)

ALTER TABLE Students
ADD ModificationDate DATETIME2 DEFAULT GETDATE() 


CREATE TRIGGER UpdateInsteadOfDelete
ON Students
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @id INT
	SELECT @id=Id FROM deleted
	--SELECT * FROM deleted
	UPDATE Students SET IsDeleted = 'true' WHERE Id=@id
END

CREATE TRIGGER UpdateModificationDate
ON Students
AFTER UPDATE
AS
BEGIN
	DECLARE @Id INT
	SELECT @Id=Id FROM inserted
	UPDATE Students SET ModificationDate = GETDATE()
	WHERE Id=@Id
END

UPDATE Students SET Fullname = 'test'
WHERE Id = 1

SELECT * FROM Students

CREATE TABLE StudentsCopy(
	Id INT,
	Fullname NVARCHAR(100)
)

CREATE TRIGGER InsertToBackup
ON Students
AFTER INSERT
AS
BEGIN
	DECLARE @Id INT, @Fullname NVARCHAR(100)
	SELECT @Id=Id, @Fullname=Fullname FROM inserted
	INSERT INTO StudentsCopy
	VALUES (@Id, @Fullname)
END

INSERT INTO Students (Fullname)
VALUES ('Test testov')

SELECT * FROM StudentsCopy


DELETE FROM Students 
WHERE Id = 7



--Soft delete
