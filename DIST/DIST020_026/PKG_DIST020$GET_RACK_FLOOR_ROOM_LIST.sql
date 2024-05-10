CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_DIST020$GET_RACK_FLOOR_ROOM_LIST`(
			IN A_RACK_DIV 		bigint(20),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SELECT 
	      A.RACK_DIV,
	      A.RACK_CODE,
	      LPAD(A.FLOOR, 3, '0') as FLOOR,
	      
	      MAX(CASE WHEN ROOM_ORDER = 1 THEN IFNULL(A.STOCK_QTY, 0) END) AS R01,
	      MAX(CASE WHEN ROOM_ORDER = 2 THEN IFNULL(A.STOCK_QTY, 0) END) AS R02,
	      MAX(CASE WHEN ROOM_ORDER = 3 THEN IFNULL(A.STOCK_QTY, 0) END) AS R03,
	      MAX(CASE WHEN ROOM_ORDER = 4 THEN IFNULL(A.STOCK_QTY, 0) END) AS R04,
	      MAX(CASE WHEN ROOM_ORDER = 5 THEN IFNULL(A.STOCK_QTY, 0) END) AS R05,
	      MAX(CASE WHEN ROOM_ORDER = 6 THEN IFNULL(A.STOCK_QTY, 0) END) AS R06,
	      MAX(CASE WHEN ROOM_ORDER = 7 THEN IFNULL(A.STOCK_QTY, 0) END) AS R07,
	      MAX(CASE WHEN ROOM_ORDER = 8 THEN IFNULL(A.STOCK_QTY, 0) END) AS R08,
	      MAX(CASE WHEN ROOM_ORDER = 9 THEN IFNULL(A.STOCK_QTY, 0) END) AS R09,
	      MAX(CASE WHEN ROOM_ORDER = 10 THEN IFNULL(A.STOCK_QTY, 0) END) AS R10,
	      
	      MAX(CASE WHEN ROOM_ORDER = 11 THEN IFNULL(A.STOCK_QTY, 0) END) AS R11,
	      MAX(CASE WHEN ROOM_ORDER = 12 THEN IFNULL(A.STOCK_QTY, 0) END) AS R12,
	      MAX(CASE WHEN ROOM_ORDER = 13 THEN IFNULL(A.STOCK_QTY, 0) END) AS R13,
	      MAX(CASE WHEN ROOM_ORDER = 14 THEN IFNULL(A.STOCK_QTY, 0) END) AS R14,
	      MAX(CASE WHEN ROOM_ORDER = 15 THEN IFNULL(A.STOCK_QTY, 0) END) AS R15,
	      MAX(CASE WHEN ROOM_ORDER = 16 THEN IFNULL(A.STOCK_QTY, 0) END) AS R16,
	      MAX(CASE WHEN ROOM_ORDER = 17 THEN IFNULL(A.STOCK_QTY, 0) END) AS R17,
	      MAX(CASE WHEN ROOM_ORDER = 18 THEN IFNULL(A.STOCK_QTY, 0) END) AS R18,
	      MAX(CASE WHEN ROOM_ORDER = 19 THEN IFNULL(A.STOCK_QTY, 0) END) AS R19,
	      MAX(CASE WHEN ROOM_ORDER = 20 THEN IFNULL(A.STOCK_QTY, 0) END) AS R20,
	      
	      MAX(CASE WHEN ROOM_ORDER = 21 THEN IFNULL(A.STOCK_QTY, 0) END) AS R21,
	      MAX(CASE WHEN ROOM_ORDER = 22 THEN IFNULL(A.STOCK_QTY, 0) END) AS R22,
	      MAX(CASE WHEN ROOM_ORDER = 23 THEN IFNULL(A.STOCK_QTY, 0) END) AS R23,
	      MAX(CASE WHEN ROOM_ORDER = 24 THEN IFNULL(A.STOCK_QTY, 0) END) AS R24,
	      MAX(CASE WHEN ROOM_ORDER = 25 THEN IFNULL(A.STOCK_QTY, 0) END) AS R25,
	      MAX(CASE WHEN ROOM_ORDER = 26 THEN IFNULL(A.STOCK_QTY, 0) END) AS R26,
	      MAX(CASE WHEN ROOM_ORDER = 27 THEN IFNULL(A.STOCK_QTY, 0) END) AS R27,
	      MAX(CASE WHEN ROOM_ORDER = 28 THEN IFNULL(A.STOCK_QTY, 0) END) AS R28,
	      MAX(CASE WHEN ROOM_ORDER = 29 THEN IFNULL(A.STOCK_QTY, 0) END) AS R29,
	      MAX(CASE WHEN ROOM_ORDER = 30 THEN IFNULL(A.STOCK_QTY, 0) END) AS R30
	FROM (
	      SELECT 
	            DISTINCT AA.RACK_DIV,
	            AA.RACK_CODE,
	            BB.FLOOR,
	            AA.ROOM,
	            SUM(STT.STOCK_QTY) as STOCK_QTY,
	            ROW_NUMBER() OVER (PARTITION BY AA.RACK_DIV, BB.FLOOR 
	                               ORDER BY AA.ROOM) AS ROOM_ORDER
	      FROM TB_RACK AA
	      LEFT JOIN (
	                   SELECT DISTINCT RACK_DIV, FLOOR 
	                   FROM TB_RACK
	              ) BB ON AA.FLOOR = BB.FLOOR AND AA.RACK_DIV = BB.RACK_DIV
	      LEFT JOIN TB_STOCK STT
	            ON STT.WARE_POS = AA.RACK_CODE
	        GROUP BY AA.RACK_DIV, BB.FLOOR, AA.ROOM
	    ) AS A
	LEFT JOIN TB_STOCK ST
	    ON ST.WARE_POS = A.RACK_CODE
	WHERE CASE 
			  WHEN A_RACK_DIV != 0
			  THEN FIND_IN_SET(A.RACK_DIV, A_RACK_DIV)
			  ELSE A.RACK_DIV LIKE '%'
		  END 
	GROUP BY A.RACK_DIV, A.FLOOR

	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END