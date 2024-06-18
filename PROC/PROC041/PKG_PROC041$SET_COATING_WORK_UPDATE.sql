CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROC041$SET_COATING_WORK_UPDATE`(	
	IN A_COMP_ID 		varchar(10), 
	IN A_WORK_LINE 		varchar(10), 
	IN A_SET_DATE 		DATETIME, 
	IN A_WORK_KEY	 	varchar(30), 
	IN A_WORK_DATE 		DATETIME, 
	IN A_MATR_CODE 		varchar(30), 
	IN A_PROG_CODE 		varchar(10), 
	IN A_EQUI_CODE 		varchar(10),
	IN A_ORDER_KEY 		varchar(30), 
	IN A_WORK_PLAN_KEY  varchar(50), 
	IN A_LOT_NO 		varchar(30), 
	IN A_PLAN_QTY 		decimal(16, 4), 
	IN A_WORK_QTY 		decimal(16, 4),
	IN A_BAD_QTY 		decimal(16, 4), 
	IN A_SHIP_INFO 		varchar(30), 
	IN A_WORK_DEPT 		varchar(10),
	IN A_WORK_EMP 		varchar(10), 
	IN A_WARE_CODE 		bigint(20), 
	IN A_RMK 			varchar(100),
	IN A_SYS_ID 		decimal(10,0), 
	IN A_SYS_EMP_NO 	varchar(10),
	OUT N_RETURN 		INT,
	OUT V_RETURN 		VARCHAR(4000)
	)
PROC_BODY : begin
	
	declare V_WORK_KEY 		VARCHAR(50);
	declare V_SET_DATE		VARCHAR(8);
	declare V_SET_NO		VARCHAR(3);
	declare V_SET_SEQ		VARCHAR(3);
	declare V_LOT_NO		VARCHAR(30);
	declare V_PROG_SEQ		INT;
	declare V_PROD_UNIT_WET	DECIMAL(16,4);
	declare V_MATR_UNIT_WET	DECIMAL(16,4);
	declare V_FINAL_PROG_YN	VARCHAR(1);
	declare V_SUBUL_KEY		VARCHAR(100);
	declare V_WARE_CODE			bigint;
	declare V_WARE_CODE_PROC	bigint;
	declare V_ITEM_KIND			bigint;
	declare V_IO_GUBN			bigint;
	declare V_WORK_DATE		VARCHAR(8);
	declare V_PROG_CODE		bigint;
	declare	V_SUBUL_PRE_KEY	VARCHAR(100);
	declare V_PROG_KIND		bigint;
	declare V_LOT_STATE_DET		bigint;
	declare V_WORK_QTY		DECIMAL(16,4);
	declare V_BAD_QTY		DECIMAL(16,4);


	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

--	select CODE into V_ITEM_KIND from SYS_DATA where DATA_ID = A_ITEM_KIND;
	
	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 

  	set V_SET_DATE 	= date_format(A_SET_DATE,'%Y%m%d');
	set V_WORK_DATE = date_format(A_WORK_DATE,'%Y%m%d');

	SET V_PROG_KIND = 40879; -- cfg.code.lot.init LOT생성사유 공정생산  
	set V_ITEM_KIND = 145919; -- cfg.item.M (원자재)
	set V_LOT_STATE_DET = 40809; -- cfg.code.lot.status 정상  
  
	select PROG_SEQ, FINAL_YN 
	into V_PROG_SEQ, V_FINAL_PROG_YN
	from   TB_ITEM_PROG 
	where  COMP_ID = A_COMP_ID 
	and ITEM_CODE = A_ITEM_CODE 
	and PROG_CODE = A_PROG_CODE;

	select PROD_UNIT_WET, MATR_UNIT_WET 
	into V_PROD_UNIT_WET, V_MATR_UNIT_WET
	from   tb_item_code
	where  ITEM_CODE = A_ITEM_CODE;

	select work_QTY, BAD_QTY 
	into V_WORK_QTY, V_BAD_QTY
	from   TB_COATING_WORK
	where  COMP_ID = A_COMP_ID 
	and WORK_KEY = A_WORK_KEY;		

	select WARE_CODE, WARE_CODE_PROC 
	into V_WARE_CODE, V_WARE_CODE_PROC
	from   dept_code
	where  DEPT_CODE = A_WORK_DEPT;

	set V_SUBUL_KEY = concat('TB_COATING_WORK-', V_WORK_KEY);
	
	/*
	-- 수불생성 (공정중 실적 내역은 선점 처리 안함) 최종공정일때만 선점처리함 
	if V_FINAL_PROG_YN = 'Y' then -- 최종공정일때 
		# 제품입고수불(최종공정)
		set V_IO_GUBN = 169917; -- 생산입고(최종공정)
		set V_PROG_CODE = 100; -- 재고상태
		call SP_SUBUL_CREATE(
			A_COMP_ID, V_SUBUL_KEY, 'UPDATE', V_WORK_DATE, '1', V_WARE_CODE, V_ITEM_KIND, A_ITEM_CODE, A_LOT_NO, V_PROG_CODE, 
			V_IO_GUBN, A_WORK_QTY - A_BAD_QTY, 0, 0, 'TB_COATING_WORK', A_WORK_KEY, 'Y', 1, '', '', 
			'N', V_WORK_DATE, A_ORDER_KEY, 'N', 'Y', 'Y', 
			A_SYS_ID, A_SYS_EMP_NO, N_RETURN, V_RETURN );
		if N_RETURN = -1 then
			leave PROC_BODY;
		end if;			
	else
		# 재공입고수불(현재공정)
		set V_IO_GUBN = 169911; -- 생산공정입고

		call SP_SUBUL_CREATE(
			A_COMP_ID, V_SUBUL_KEY, 'UPDATE', V_WORK_DATE, '1', V_WARE_CODE_PROC, V_ITEM_KIND, A_ITEM_CODE, A_LOT_NO, A_PROG_CODE, 
			V_IO_GUBN, A_WORK_QTY - A_BAD_QTY, 0, 0, 'TB_COATING_WORK', V_WORK_KEY, 'Y', 1, '', '', 
			'N', V_WORK_DATE, A_ORDER_KEY, 'N', 'Y', 'Y', 
			A_SYS_ID, A_SYS_EMP_NO, N_RETURN, V_RETURN );
		if N_RETURN = -1 then
			leave PROC_BODY;
		end if;	
	end if;

	if A_PROG_CODE_PRE is not null AND A_PROG_CODE_PRE <> 0 THEN
		# 재공입고수불(이전공정)
		set V_IO_GUBN = 169918; -- 생산공정출고
		set V_SUBUL_PRE_KEY = CONCAT(V_SUBUL_KEY, 'PRE');  
		call SP_SUBUL_CREATE(
			A_COMP_ID, V_SUBUL_PRE_KEY, 'UPDATE', V_WORK_DATE, '2', V_WARE_CODE_PROC, V_ITEM_KIND, A_ITEM_CODE, A_LOT_NO, A_PROG_CODE_PRE, 
			V_IO_GUBN, A_WORK_QTY, 0, 0, 'TB_COATING_WORK', V_WORK_KEY, 'Y', 1, '', '', 
			'N', V_WORK_DATE, A_ORDER_KEY, 'N', 'Y', 'Y', 
			A_SYS_ID, A_SYS_EMP_NO, N_RETURN, V_RETURN );
		if N_RETURN = -1 then
			leave PROC_BODY;
		end if;			
	end if;
	*/
	
	update TB_COATING_PLAN_DET 
	set    WORK_QTY = WORK_QTY - (V_WORK_QTY - V_BAD_QTY) +  (A_WORK_QTY - A_BAD_QTY)
	where  COMP_ID = A_COMP_ID 
	  and WORK_PLAN_KEY = A_WORK_PLAN_KEY;

	update TB_COATING_WORK
	set    WORK_QTY = A_WORK_QTY,
		   BAD_QTY	= A_BAD_QTY,
		   END_TIME = SYSDATE(),
		   WORK_EMP	= A_WORK_EMP,
		   WORK_DATE = V_WORK_DATE,
		   RMK	= A_RMK,
		   UPD_ID = A_SYS_ID,
		   UPD_EMP_NO = A_SYS_EMP_NO,
		   UPD_DATE = SYSDATE()
	where  COMP_ID = A_COMP_ID 
	  and WORK_KEY = A_WORK_KEY;		   
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
END