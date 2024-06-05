CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROD035$SET_COATING_PLAN_INSERT`(	
	IN A_COMP_ID		varchar(10),
    IN A_MATR_LOT_NO	varchar(30),
#    IN V_SET_SEQ		varchar(2),
    INOUT A_PLAN_MST_KEY	varchar(50),
    IN A_WORK_LINE		varchar(10),
    IN A_ORDER_KEY		varchar(30),
    IN A_MATR_CODE		varchar(30),
    IN A_PROG_CODE		varchar(10),
    IN A_PLAN_TOT_QTY	decimal(16, 4),
    IN A_STOCK_QTY		decimal(16, 4),
    IN A_DEPT_CODE		varchar(10),
    IN A_WARE_CODE		bigint(20),
    IN A_RMK			varchar(100),
	IN A_SYS_ID 		decimal(10,0), 
	IN A_SYS_EMP_NO 	varchar(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	declare V_PLAN_MST_KEY VARCHAR(50);
	declare V_SET_SEQ varchar(2);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	set V_SET_SEQ = (select LPAD(IFNULL(MAX(SET_SEQ), 0) + 1, 2, '0')
  					 from TB_COATING_PLAN
  					 where MATR_LOT_NO = A_MATR_LOT_NO
  					   and WORK_LINE = A_WORK_LINE);
  
  	set V_PLAN_MST_KEY = CONCAT(A_MATR_LOT_NO, A_WORK_LINE, V_SET_SEQ); # 계획 MST KEY (원자재LOT NO + 생산라인 + 순번(2))
  
    
    insert into TB_COATING_PLAN (
    	COMP_ID,
    	MATR_LOT_NO,
    	SET_SEQ,
    	PLAN_MST_KEY,
    	WORK_LINE,
    	ORDER_KEY,
    	MATR_CODE,
    	PROG_CODE,
    	PLAN_TOT_QTY,
    	STOCK_QTY,
    	DEPT_CODE,
    	WARE_CODE,
    	RMK,
    	SYS_EMP_NO,
    	SYS_ID,
    	SYS_DATE
    ) values (
   		A_COMP_ID,
    	A_MATR_LOT_NO,
    	V_SET_SEQ,
    	V_PLAN_MST_KEY,
    	A_WORK_LINE,
    	A_ORDER_KEY,
    	A_MATR_CODE,
    	A_PROG_CODE,
    	A_PLAN_TOT_QTY,
    	A_STOCK_QTY,
    	A_DEPT_CODE,
    	A_WARE_CODE,
    	A_RMK,
    	A_SYS_ID,
		A_SYS_EMP_NO,
		SYSDATE()
    );
				
    set A_PLAN_MST_KEY = V_PLAN_MST_KEY;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
END