CREATE DATABASE TNUT

CREATE TABLE Mon_Hoc (
	ID_MH VARCHAR(50) PRIMARY KEY,
	Ten_MH NVARCHAR(50) not null,
	STC INT not null CHECK (STC>0)
);

CREATE TABLE SV (
	Ma_SV VARCHAR(50) PRIMARY KEY,
	Ten_SV NVARCHAR(50) not null,
	Sex NVARCHAR(50) not null,
	Lop_SV NVARCHAR(50) not null
);

CREATE TABLE GV (
	ID_GV VARCHAR(50) PRIMARY KEY,
	Ten_GV NVARCHAR(50) not null,
	Bo_Mon NVARCHAR(50) not null
);	

CREATE TABLE Lop_HP (
	ID_LOP_HP VARCHAR(50) PRIMARY KEY,
	ID_MH VARCHAR(50),
	CONSTRAINT fk_ID_MH FOREIGN KEY (ID_MH) REFERENCES Mon_Hoc(ID_MH),
	Hoc_Ky INT not null,
	Ten_Lop_HP NVARCHAR(50) not null,
	ID_GV VARCHAR(50) FOREIGN KEY (ID_GV) REFERENCES GV(ID_GV)
);

CREATE TABLE DKMH (
	ID VARCHAR(50) PRIMARY KEY,
	ID_LOP_HP VARCHAR(50) FOREIGN KEY (ID_LOP_HP) REFERENCES Lop_HP(ID_LOP_HP),
	Ma_SV VARCHAR(50) FOREIGN KEY (Ma_SV) REFERENCES SV(Ma_SV),
	Diem_KT FLOAT NOT NULL CHECK (Diem_KT >= 0 AND Diem_KT <=10),
	Diem_Thi FLOAT NOT NULL CHECK (Diem_Thi >= 0 AND Diem_Thi <=10),
);

INSERT INTO Mon_Hoc 
VALUES (1,N'Hệ điều hành',3),
	   (2,N'Xử lý ảnh',3),
	   (3,N'Mạng máy tính',3),
	   (4,N'Hệ thống nhúng',2);

INSERT INTO SV
VALUES ('K215480106129',N'Phạm Quang Trường', N'Nam', '57KMT'),
	   ('K215480106123',N'La Đức Thắng', N'Nam', '57KMT'),
	   ('K215480106110',N'Nguyễn Thị Chà My', N'Nữ', '57KMT');

INSERT INTO GV
VALUES ('100',N'Nguyễn Văn Huy','TNCN'),
	   ('101',N'Đặng Thị Hiên','TNCN'),
	   ('102',N'Nghiêm Văn Tính','TNCN'),
	   ('103',N'Tăng Cẩm Nhung','TNCN');

INSERT INTO Lop_HP
VALUES ('1','1',2,'111121531','100'),
	   ('2','2',2,'111121531','101'),
	   ('3','3',2,'111121531','102'),
	   ('4','4',2,'111121531','103');

INSERT INTO DKMH
VALUES ('1','1','K215480106129',6,7),
	   ('2','2','K215480106129',7,7),
	   ('3','3','K215480106129',6,7),
	   ('4','4','K215480106129',8,8),
	   ('5','1','K215480106123',7,7),
	   ('6','2','K215480106123',8,8),
	   ('7','3','K215480106123',6,7),
	   ('8','4','K215480106123',8,8),
	   ('9','1','K215480106110',5,8),
	   ('10','2','K215480106110',7,7),
	   ('11','3','K215480106110',6,6),
	   ('12','4','K215480106110',8,7);

--Bài 1.
CREATE FUNCTION fn_diem --Tạo funstion
(@HK INT, @Ma_SV VARCHAR(50)) --Tạo 2 biến ảo để mang đi so sánh
RETURNS FLOAT AS --funstion trả về kiểu dữ liệu là số thực
BEGIN
    DECLARE @DiemTBHK FLOAT; --Khai báo biến kiểu số thực để trả về giá trị sau khi tính toán xong
    SELECT @DiemTBHK = SUM((Diem_KT * 0.4 + Diem_Thi * 0.6)*Mon_Hoc.STC)/ SUM(Mon_Hoc.STC) --Công thức tính ĐTBHK
    FROM DKMH --Lấy dữ liệu từ bảng DKMH
    INNER JOIN Lop_HP ON DKMH.ID_LOP_HP = Lop_HP.ID_LOP_HP --Kết hợp dữ liệu từ bảng Lop_HP để lấy học kỳ
    INNER JOIN Mon_Hoc ON Lop_HP.ID_MH = Mon_Hoc.ID_MH --Kết hợp dữ liệu từ bảng Mon_Hoc để lấy STC
    WHERE DKMH.Ma_SV = @Ma_SV AND Lop_HP.Hoc_Ky = @HK; --Điều kiện là có MSV và học kỳ trùng với 2 biến ảo đưa vào hàm
    RETURN @DiemTBHK; --Trả về
END;

SELECT dbo.fn_diem(2, 'K215480106129') AS DTBHK; --Câu lệnh truy xuất

--Bài 2.
CREATE FUNCTION fn_diem_lopsv
(@HK INT,@LOPSV VARCHAR(50))
RETURNS TABLE AS --Hàm trả về 
RETURN
(
    SELECT 
        SV.Ten_SV,
        SV.Sex,
        SV.Ma_SV,
        SUM((DKMH.Diem_KT * 0.4 + DKMH.Diem_Thi * 0.6)*Mon_Hoc.STC) / SUM(Mon_Hoc.STC) AS DiemTrungBinh --Công thức tính ĐTBHK
    FROM SV
    INNER JOIN DKMH ON SV.Ma_SV = DKMH.Ma_SV --Kết hợp dữ liệu từ bảng DKMH để lấy điểm 
    INNER JOIN Lop_HP ON DKMH.ID_LOP_HP = Lop_HP.ID_LOP_HP  --Kết hợp dữ liệu từ bảng LOP_HP để lấy học kỳ
    INNER JOIN Mon_Hoc ON Lop_HP.ID_MH = Mon_Hoc.ID_MH  --Kết hợp dữ liệu từ bảng Mon_Hoc để lấy số tín chỉ
    WHERE SV.Lop_SV = @LOPSV AND Lop_HP.Hoc_Ky = @HK --Điều kiện
    GROUP BY SV.Ten_SV, SV.Sex, SV.Ma_SV --Nhóm dữ liệu và để dùng các hàm tính toán 
);

SELECT * FROM dbo.fn_diem_lopsv(2,'57KMT');

---Bài 4.
CREATE PROCEDURE DSSVDKLHP -- tạo một stored procedure
(@id_LOP_HP VARCHAR(50)) --Đầu vào
AS BEGIN --Bắt đầu phần thân của của procedure
    DECLARE @json NVARCHAR(MAX); --tạo một biến @json có kiểu ncvarchar và lưu trữ một chuỗi lớn
    SELECT @json = (
        SELECT
            sv.Ma_SV AS MSV,
            sv.Ten_SV AS NAME,
            sv.Sex AS SEX,
            sv.Lop_SV AS LOPSV
        FROM SV
        INNER JOIN DKMH ON SV.Ma_SV = DKMH.Ma_SV --kết hợp dữ liệu từ bảng DKMH để sử dụng điều kiện xem sinh viên có đk lớp ko
        WHERE DKMH.ID_LOP_HP = @id_LOP_HP --So sánh biến đầu vào để tìm lớp học phần 
        FOR JSON PATH --tạo cấu trúc JSON 
    );
    SELECT @json AS json_data; --đẩy dữ liệu trong @json ra đầu ra của procedure
END;

EXEC DSSVDKLHP @id_LOP_HP = '1';--Truy vấn

-----Bài 5.
CREATE PROCEDURE DSMHGVGD
(@id_gv VARCHAR(50),@hk INT) --Tạo 2 biến đầu vào
AS BEGIN --Bắt đầu phần thân của của procedure
    DECLARE @json NVARCHAR(MAX); --tạo một biến @json có kiểu ncvarchar và lưu trữ một chuỗi lớn
    SELECT @json = (
        SELECT
            Mon_Hoc.ID_MH AS id,
            Mon_Hoc.Ten_MH AS name,
            Mon_Hoc.STC AS STC
        FROM Mon_Hoc
        INNER JOIN Lop_HP ON Mon_Hoc.ID_MH = Lop_HP.ID_MH --Kết hợp dữ liệu từ bảng Lop_HP
        WHERE Lop_HP.ID_GV = @id_gv AND Lop_HP.Hoc_Ky = @hk --Dùng @id_gv và @hk vào để so sánh xem giáo viên đó có dạy trong hk đó
        FOR JSON PATH--tạo cấu trúc JSON 
    );
    SELECT @json AS json_data;--đẩy dữ liệu trong @json ra đầu ra của procedure
END;

EXEC DSMHGVGD @id_gv = '100', @hk = 2;--Truy vấn


