CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_DIST020$GET_RACK_FLOOR_ROOM_LIST`(
			IN A_RACK_DIV 		bigint(20),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 
		   A.RACK_DIV,
		   LPAD(A.FLOOR, 2, '0') as FLOOR,
 		   MAX(case when ROOM_ORDER = 1 then ROOM END) as R01,
		   MAX(case when ROOM_ORDER = 2 then ROOM END) as R02,
		   MAX(case when ROOM_ORDER = 3 then ROOM END) as R03,
		   MAX(case when ROOM_ORDER = 4 then ROOM END) as R04,
		   MAX(case when ROOM_ORDER = 5 then ROOM END) as R05,
		   MAX(case when ROOM_ORDER = 6 then ROOM END) as R06,
		   MAX(case when ROOM_ORDER = 7 then ROOM END) as R07,
		   MAX(case when ROOM_ORDER = 8 then ROOM END) as R08,
		   MAX(case when ROOM_ORDER = 9 then ROOM END) as R09,
		   MAX(case when ROOM_ORDER = 10 then ROOM END) as R10
	from (
		  select
		  		AA.RACK_CODE,
			    AA.RACK_NAME,
			    AA.RACK_DIV,
			    AA.FLOOR,
			    AA.ROOM,
			    AA.SPEC,
			    AA.SIZE_R,
			    AA.SIZE_V,
			    AA.SIZE_H,
			    AA.RMK,
			    ROW_NUMBER() OVER (PARTITION BY AA.RACK_DIV, AA.FLOOR 
			    				   ORDER BY AA.ROOM) AS ROOM_ORDER
		   from TB_RACK AA
		  ) as A
	where case 
			  when A_RACK_DIV != 0
			  then FIND_IN_SET(A.RACK_DIV, A_RACK_DIV)
			  else A.RACK_DIV like '%'
		  end 
	group by A.RACK_DIV
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END