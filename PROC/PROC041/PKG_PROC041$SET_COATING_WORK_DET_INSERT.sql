CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROC041$SET_COATING_WORK_DET_INSERT`(	
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
	declare V_WARE_CODE			bigint;
	declare V_ITEM_KIND			bigint;
	declare V_IO_GUBN			bigint;
	DECLARE V_INPUT_REAL_QTY DECIMAL(16,4);
	declare V_STOCK_QTY		DECIMAL(16,4);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 

  	
  	set V_SET_DATE = date_format(A_SET_DATE,'%Y%m%d');
    
	select WARE_CODE 
	into V_WARE_CODE
	from   dept_code
	where  DEPT_CODE = A_WORK_DEPT;

	set V_ITEM_KIND = 145919; -- cfg.item.M (원자재)
	set V_SUBUL_KEY = concat('TB_COATING_WORK_DET-', A_WORK_KEY, A_LOT_NO);

	if A_MATR_END_YN = 'Y' then -- 원자재 사용완료일때 처리	
		select STOCK_QTY into V_STOCK_QTY
		from   tb_stock
		where  COMP_ID = A_COMP_ID 
		 and WARE_CODE = A_WARE_CODE 
		 and ITEM_CODE = A_ITEM_CODE 
		 and LOT_NO = A_LOT_NO;
		
		if V_STOCK_QTY > 0 then 
			set V_INPUT_REAL_QTY = V_STOCK_QTY;
		end if;	
	else 
		set V_INPUT_REAL_QTY = A_INPUT_QTY;
	end if;
		
	# 원자재공정투입출고수불
	set V_IO_GUBN = 34304; -- 생산공정투입
	
	call SP_SUBUL_CREATE(
		A_COMP_ID, V_SUBUL_KEY, 'INSERT', V_SET_DATE, '2', V_WARE_CODE, V_ITEM_KIND, A_MATR_CODE, A_LOT_NO, A_PROG_CODE, 
		V_IO_GUBN, V_INPUT_REAL_QTY, 0, 0, 'TB_COATING_WORK_DET', concat(A_WORK_KEY, A_LOT_NO), 'Y', 1, '', '', 
		'N', V_SET_DATE, '', 'N', 'Y', 'Y', 
		A_SYS_ID, A_SYS_EMP_NO, N_RETURN, V_RETURN );
	if N_RETURN = -1 then
		leave PROC_BODY;
	end if;		


  	insert into TB_COATING_WORK_DET (
  		COMP_ID, WORK_LINE, WORK_KEY, WORK_DATE, MATR_CODE,
  		PROG_CODE, LOT_NO, WORK_QTY, WORK_DEPT, WARE_CODE,
  		RMK,
  		SYS_EMP_NO, SYS_ID, SYS_DATE
  	) values (
  		A_COMP_ID, A_WORK_LINE, A_WORK_KEY, A_WORK_DATE, A_MATR_CODE,
  		A_PROG_CODE, A_LOT_NO, A_WORK_QTY, A_WORK_DEPT, A_WARE_CODE,
  		A_RMK,
  		A_SYS_EMP_NO, A_SYS_ID, SYSDATE()
  	)
  	;
							
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
END