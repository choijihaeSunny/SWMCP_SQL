CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROC041$GET_COATING_WORK_PLAN_CALL`(	
	in A_COMP_ID VARCHAR(10),
	in A_DATE1	 DATETIME,
	in A_DATE2	 DATETIME,
	in A_WORK_LINE	VARCHAR(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	
	select	
		  'N' as IS_CHECK,
		  A.COMP_ID,
		  A.WORK_PLAN_KEY, 
		  A.WORK_LINE, 
		  A.PLAN_MST_KEY,
		  A.PLAN_DATE,
		  A.MATR_CODE,
		  C.ITEM_NAME,
		  C.ITEM_SPEC,
		  D.LOT_NO,
		  A.PLAN_QTY - A.WORK_QTY as PLAN_QTY,
		  A.DEPT_CODE, --
		  A.CONFIRM_YN,
		  A.WORK_QTY, 
		  A.END_YN, 
	      A.RMK,
	      B.PROG_CODE,
	      B.ORDER_KEY,
	      B.WARE_CODE,
	      (select WARE_CODE_PROC
	      	from  dept_code
	      	where DEPT_CODE = A.DEPT_CODE) as WARE_CODE_PROC 
	from TB_COATING_PLAN_DET A
		inner join TB_ITEM_CODE C 
			on A.MATR_CODE = C.ITEM_CODE
		inner join TB_COATING_PLAN B 
			on A.COMP_ID = B.COMP_ID
		   and A.PLAN_MST_KEY = B.PLAN_MST_KEY
	    inner join TB_STOCK D
			on A.COMP_ID = D.COMP_ID
		   and A.MATR_CODE = D.ITEM_CODE 
		   and A.MATR_LOT_NO = D.LOT_NO
		   and B.WARE_CODE = D.WARE_CODE 
	where A.COMP_ID = A_COMP_ID
	  and A.PLAN_DATE between date_format(A_DATE1, '%Y%m%d') and date_format(A_DATE2, '%Y%m%d')
	  and A.WORK_LINE LIKE CONCAT('%', A_WORK_LINE, '%')
	  and A.CONFIRM_YN = 'Y'
	  and A.END_YN = 'N'
	  and A.PLAN_QTY - A.WORK_QTY > 0	;
		
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
   
END