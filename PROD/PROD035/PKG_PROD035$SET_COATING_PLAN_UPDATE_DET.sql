CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROD035$SET_COATING_PLAN_UPDATE_DET`(	
	IN A_COMP_ID varchar(10),
	IN A_MATR_LOT_NO varchar(30),
	IN A_PLAN_DATE varchar(8),
-- 	IN A_ORDER_KEY		varchar(30),
	IN A_WORK_LINE varchar(10),
	IN A_PROG_CODE varchar(10),
	IN A_PLAN_QTY decimal(16, 4),
	IN A_RMK varchar(100),
	IN A_SYS_ID decimal(10,0), 
	IN A_SYS_EMP_NO varchar(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_TOT_QTY DECIMAL;
	declare V_PLAN_QTY2 DECIMAL;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 

    
	UPDATE TB_COATING_PLAN_DET 
		set PLAN_QTY = A_PLAN_QTY,
			PROG_CODE = A_PROG_CODE,
			RMK = A_RMK,
			UPD_ID = A_SYS_ID,
  			UPD_EMP_NO = A_SYS_EMP_NO,
  			UPD_DATE = SYSDATE()
	where COMP_ID = A_COMP_ID
-- 	  and ORDER_KEY = A_ORDER_KEY
	  and WORK_LINE = A_WORK_LINE
	  and PLAN_DATE = A_PLAN_DATE
	;


	-- 총 수량 MST 테이블에 반영
	select SUM(PLAN_QTY) 
	into V_TOT_QTY
	from TB_COATING_PLAN_DET
	where COMP_ID = A_COMP_ID
	  and MATR_LOT_NO = A_MATR_LOT_NO
	  and WORK_LINE = A_WORK_LINE
	;

-- 	select NVL(SUM(PLAN_TOT_QTY), 0)
-- 	into V_PLAN_QTY2
-- 	from TB_COATING_PLAN
-- 	where COMP_ID = A_COMP_ID
-- 	  and ORDER_KEY = A_ORDER_KEY
-- 	  and WORK_LINE = A_WORK_LINE
-- 	;

	update TB_COATING_PLAN
		set PLAN_TOT_QTY = V_TOT_QTY
	where COMP_ID = A_COMP_ID
-- 	  and ORDER_KEY = A_ORDER_KEY
	  and WORK_LINE = A_WORK_LINE
	;
	  
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
END