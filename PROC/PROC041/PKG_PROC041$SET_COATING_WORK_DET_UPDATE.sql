CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROC041$SET_COATING_WORK_DET_UPDATE`(	
	IN A_COMP_ID varchar(10), 
	IN A_WORK_LINE varchar(10), 
	IN A_WORK_KEY varchar(30), 
	IN A_WORK_DATE DATETIME, 
	IN A_MATR_CODE varchar(30),
	IN A_PROG_CODE varchar(10), 
	IN A_LOT_NO varchar(30), 
	IN A_WORK_QTY decimal(16, 4), 
	IN A_WORK_DEPT varchar(10), 
	IN A_WARE_CODE bigint(20),
	IN A_RMK varchar(100),
	IN A_SYS_ID decimal(10,0), 
	IN A_SYS_EMP_NO varchar(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
PROC_BODY : begin
	declare V_WORK_KEY 		VARCHAR(50);
	declare V_SET_DATE		VARCHAR(8);
	declare V_SUBUL_KEY		VARCHAR(100);
	declare V_ITEM_KIND			bigint;
	declare V_IO_GUBN			bigint;
	declare V_STOCK_QTY		DECIMAL(16,4);
	declare V_WORK_QTY		DECIMAL(16,4);

	declare V_PROG_KIND		bigint;
	declare V_LOT_STATE_DET		bigint;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

--	select CODE into V_ITEM_KIND from SYS_DATA where DATA_ID = A_ITEM_KIND;
	
	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 

  	set V_SET_DATE = date_format(A_SET_DATE,'%Y%m%d');
    
	SET V_PROG_KIND = 40879; -- cfg.code.lot.init LOT생성사유 공정생산  
	set V_ITEM_KIND = 145919; -- cfg.item.M (원자재)
	set V_LOT_STATE_DET = 40809; -- cfg.code.lot.status 정상  
	
	call PKG_LOT$CREATE_ITEM_LOT_IUD ('UPDATE', A_COMP_ID, A_LOT_NO, '', '', A_SET_DATE, 'LM', '', A_ITEM_CODE,
									  '', 0, 0, '', '', 'NORMAL', V_LOT_STATE_DET, 0, 0, 'TB_COATING_WORK_DET', A_WORK_KEY,
									  A_ORDER_KEY, A_PROG_CODE, 0, V_PROG_KIND, '', V_ITEM_KIND, 'NEW', V_PROD_UNIT_WET, V_MATR_UNIT_WET,
									  '', 0, 0, V_PROG_KIND, 'Y', A_SYS_ID, A_SYS_EMP_NO, V_LOT_NO, N_RETURN, V_RETURN);
	if N_RETURN = -1 then
		leave PROC_BODY;
	end if;

	set V_SUBUL_KEY = concat('TB_COATING_WORK_DET-', A_WORK_KEY, A_LOT_NO);

	select WORK_QTY
	into V_WORK_QTY
	from   TB_COATING_WORK_DET 
	where  COMP_ID = A_COMP_ID 
	  and WORK_KEY = A_WORK_KEY 
	  and LOT_NO_MATR = A_LOT_NO
	;

	call SP_SUBUL_CREATE(
		A_COMP_ID, V_SUBUL_KEY, 'UPDATE', V_SET_DATE, '1', V_WARE_CODE, V_ITEM_KIND, A_MATR_CODE, V_LOT_NO, A_PROG_CODE, 
		V_IO_GUBN, V_INPUT_REAL_QTY, 0, 0, 'TB_COATING_WORK_DET', concat(A_WORK_KEY, V_LOT_NO), 'Y', 1, '', '', 
		'N', V_SET_DATE, '', 'N', 'Y', 'Y', 
		A_SYS_ID, A_SYS_EMP_NO, N_RETURN, V_RETURN );
	if N_RETURN = -1 then
		leave PROC_BODY;
	end if;	

	update TB_COATING_WORK_DET 
	set    WORK_QTY = A_WORK_QTY,
		   RMK = A_RMK,
		   UPD_EMP_NO = A_SYS_EMP_NO,
		   UPD_ID = A_SYS_ID,
		   UPD_DATE = SYSDATE()
	where COMP_ID = A_COMP_ID 
 	  and WORK_KEY = A_WORK_KEY 
 	  and LOT_NO = A_LOT_NO;		   
		
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
END