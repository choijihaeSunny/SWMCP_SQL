CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROD035$SET_COATING_PLAN_INSERT_DET`(	
	IN A_COMP_ID varchar(10),
	IN A_MATR_LOT_NO varchar(30),
#	IN A_SET_SEQ varchar(2),
	IN A_PLAN_DATE varchar(8),
	IN A_PLAN_MST_KEY varchar(50),
-- 	IN A_ORDER_KEY		varchar(30),
#	IN A_WORK_PLAN_KEY varchar(50),
	IN A_WORK_LINE varchar(10),
	IN A_MATR_CODE varchar(30),
	IN A_PROG_CODE varchar(10),
	IN A_PLAN_QTY decimal(16, 4),
	IN A_DEPT_CODE varchar(10),
	IN A_WORK_QTY decimal(16, 4),
	IN A_RMK varchar(100),
	IN A_SYS_ID decimal(10,0), 
	IN A_SYS_EMP_NO varchar(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_WORK_PLAN_KEY VARCHAR(50);
	declare V_TOT_QTY DECIMAL;
	declare V_PLAN_QTY2 DECIMAL;
	declare V_SET_SEQ varchar(2);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
	set V_WORK_PLAN_KEY = CONCAT(A_PLAN_MST_KEY, A_PLAN_DATE); -- 생산계획 KEY (계획MST KEY + 계획일자)
  	
	set V_SET_SEQ = (select LPAD(IFNULL(MAX(SET_SEQ), 0) + 1, 2, '0')
					 from TB_COATING_PLAN_DET
					 where PLAN_DATE = A_PLAN_DATE
					   and PLAN_MST_KEY = A_PLAN_MST_KEY);
    
	insert into TB_COATING_PLAN_DET (
		COMP_ID,
		MATR_LOT_NO,
		SET_SEQ,
		PLAN_DATE,
		PLAN_MST_KEY,
		WORK_PLAN_KEY,
		WORK_LINE,
		MATR_CODE,
		PROG_CODE,
		PLAN_QTY,
		DEPT_CODE,
		WORK_QTY,
		RMK,
		SYS_ID,
		SYS_EMP_NO,
		SYS_DATE
	) values (
		A_COMP_ID,
		A_MATR_LOT_NO,
		V_SET_SEQ,
		A_PLAN_DATE,
		A_PLAN_MST_KEY,
		V_WORK_PLAN_KEY,
		A_WORK_LINE,
		A_MATR_CODE,
		A_PROG_CODE,
		A_PLAN_QTY,
		A_DEPT_CODE,
		A_WORK_QTY,
		A_RMK,
		A_SYS_ID,
		A_SYS_EMP_NO,
		SYSDATE()
	);


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