CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROC041$GET_COATING_WORK_DET`(	
	in A_COMP_ID VARCHAR(10),
	in A_WORK_KEY	VARCHAR(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  A.COMP_ID,
		  A.WORK_LINE,
		  A.WORK_KEY,
		  STR_TO_DATE(A.WORK_DATE,'%Y%m%d') as WORK_DATE,
		  A.MATR_CODE,
		  C.ITEM_NAME,
		  C.ITEM_SPEC,
		  A.PROG_CODE,
		  A.LOT_NO,
		  A.WORK_QTY,
		  A.WORK_DEPT,
		  A.WARE_CODE,
		  A.RMK
	from TB_COATING_WORK_DET A
		inner join TB_ITEM_CODE C
			on A.MATR_CODE = C.ITEM_CODE
	where A.COMP_ID = A_COMP_ID
	  and A.WORK_KEY = A_WORK_KEY
	;
		
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
   
END