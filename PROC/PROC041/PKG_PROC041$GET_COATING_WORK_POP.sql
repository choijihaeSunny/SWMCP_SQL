CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROC041$GET_COATING_WORK_POP`(	
	in A_COMP_ID VARCHAR(10),
	in A_DEPT_CODE	VARCHAR(10),
	in A_WORK_LINE	VARCHAR(10),
	in A_ST_DATE DATETIME,
	in A_ED_DATE DATETIME,
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_DATE1	VARCHAR(8);
	declare V_SET_DATE2	VARCHAR(8);
	declare V_DEPT_CODE	VARCHAR(10);
	declare V_WORK_LINE	VARCHAR(10);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET V_SET_DATE1 = date_format(A_ST_DATE,'%Y%m%d');
	SET V_SET_DATE2 = date_format(A_ED_DATE,'%Y%m%d');

	if A_DEPT_CODE is null or A_DEPT_CODE = '' then 
		set V_DEPT_CODE = '%';
	else 
		set V_DEPT_CODE = A_DEPT_CODE;
	end if;
	if A_WORK_LINE is null or A_WORK_LINE = '' then 
		set V_WORK_LINE = '%';
	else 
		set V_WORK_LINE = A_WORK_LINE;
	end if;


	select
	      A.COMP_ID,
	      str_to_date(A.SET_DATE,'%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
	      A.SET_NO,
	      A.WORK_KEY,
	      A.MATR_CODE,
	      C.ITEM_NAME,
	      C.ITEM_SPEC,
	      A.WORK_QTY,
	      A.BAD_QTY,
	      A.SHIP_INFO,
	      A.WORK_LINE,
	      A.WORK_DEPT,
	      A.LOT_NO,
	      A.RMK
	from TB_COATING_WORK A
		inner join TB_ITEM_CODE C 
			on A.MATR_CODE = C.ITEM_CODE
			
	where A.COMP_ID = A_COMP_ID
	  and NVL(A.SET_DATE, date_format(A.SYS_DATE,'%Y%m%d')) between V_SET_DATE1 and V_SET_DATE2
	  and A.WORK_DEPT LIKE V_DEPT_CODE
	  and A.WORK_LINE LIKE V_WORK_LINE
	;
	
		
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
   
END