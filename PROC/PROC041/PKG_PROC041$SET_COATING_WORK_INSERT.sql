CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROC041$SET_COATING_WORK_INSERT`(	
	IN A_COMP_ID 		varchar(10), 
	IN A_WORK_LINE 		varchar(10), 
	IN A_SET_DATE 		DATETIME, 
	IN A_SET_SEQ 		varchar(3), 
	IN A_SET_NO 		varchar(3),
	INOUT A_WORK_KEY 	varchar(30), 
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
	

	declare V_WORK_KEY 			varchar(50);
	declare V_SET_DATE 			VARCHAR(8);
	declare V_SET_NO 			varchar(3);
	declare V_SET_SEQ 			varchar(3);
	declare V_LOT_NO 			varchar(30);
	declare V_YYMM 				varchar(4);
	declare V_LOT_SEQ 			varchar(5);
	declare V_PROG_SEQ			INT;
	declare V_PROD_UNIT_WET		DECIMAL(16,4);
	declare V_MATR_UNIT_WET		DECIMAL(16,4);
	declare V_FINAL_PROG_YN		VARCHAR(1);
	declare V_SUBUL_KEY			VARCHAR(100);
	declare V_SUBUL_ORDER_KEY	VARCHAR(100);
	declare V_WARE_CODE			bigint;
	declare V_WARE_CODE_PROC	bigint;
	declare V_ITEM_KIND			bigint;
	declare V_IO_GUBN			bigint;
	declare V_PROG_CODE			bigint;
	declare	V_SUBUL_PRE_KEY		VARCHAR(100);
	declare V_PROG_KIND			bigint;
	declare V_LOT_STATE_DET 	bigint;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	SET V_PROG_KIND = 40879; -- cfg.code.lot.init LOT생성사유 공정생산  
	set V_ITEM_KIND = 145919; -- cfg.item.M (원자재)
	set V_LOT_STATE_DET = 40809; -- cfg.code.lot.status 정상 
	
	set V_SET_DATE = date_format(A_SET_DATE, '%Y%m%d');
    set V_SET_SEQ = TRIM(LMAD(CONVERT(A_SET_SEQ, INT), 3, '0'));
   
    select TRIM(LMAD(CONVERT(NVL(MAX(SET_NO), '0') , INT) + 1, 3, '0'))
    into V_SET_NO
    from TB_COATING_WORK
    where COMP_ID = A_COMP_ID
      and WORK_LINE = A_WORK_LINE
      and SET_DATE = V_SET_DATE
      and SET_SEQ = V_SET_SEQ
    ;
   
    -- WR 물어보고 변경 필요
#    set V_WORK_KEY = CONCAT('MC', A_WORK_LINE, V_SET_DATE, V_SET_SEQ, V_SET_NO);
    set V_WORK_KEY = CONCAT('MC', V_SET_DATE, V_SET_SEQ, V_SET_NO);
    set A_WORK_KEY = V_WORK_KEY;
   
    select PROG_SEQ, FINAL_YN 
    into V_PROG_SEQ, V_FINAL_PROG_YN
	from   TB_ITEM_PROG 
	where  COMP_ID = A_COMP_ID 
      and ITEM_CODE = A_ITEM_CODE 
      and PROG_CODE = A_PROG_CODE
    ;
   
    select PROD_UNIT_WET, MATR_UNIT_WET 
    into V_PROD_UNIT_WET, V_MATR_UNIT_WET
	from  TB_ITEM_CODE
	where  ITEM_CODE = A_MATR_CODE;
   
    set V_PROG_CODE = A_PROG_CODE;
	
   	
   -- 생산 LOT NO 없을때  생성 
   	if A_LOT_NO is null or A_LOT_NO = '' then
    	call PKG_LOT$CREATE_ITEM_LOT_IUD ('INSERT', A_COMP_ID, '', SUBSTRING(V_SET_DATE,3,4), '', A_SET_DATE, 'LM', '', A_MATR_CODE,
										  '', 0, 0, '', '', 'NORMAL', V_LOT_STATE_DET, A_WORK_QTY - A_BAD_QTY, 0, 'TB_COATING_WORK', V_WORK_KEY,
										  A_ORDER_KEY, A_PROG_CODE, V_PROG_SEQ, V_PROG_KIND, '', V_ITEM_KIND, 'NEW', V_PROD_UNIT_WET, V_MATR_UNIT_WET,
										  '', 0, 0, V_PROG_KIND, 'Y', A_SYS_ID, A_SYS_EMP_NO, V_LOT_NO, N_RETURN, V_RETURN);
		if N_RETURN = -1 then
			leave PROC_BODY;
		end if;
										  
		set A_LOT_NO = V_LOT_NO;	
	
	else -- LOT NO가 이미 있으면 PROG로 처리 -- PROG란?
	
		set V_YYMM = SUBSTR(A_LOT_NO, 3, 4);
		set V_LOT_SEQ = SUBSTR(A_LOT_NO,7, 2);
    	call PKG_LOT$CREATE_ITEM_LOT_IUD ('INSERT', A_COMP_ID, A_LOT_NO, V_YYMM, V_LOT_SEQ, A_SET_DATE, 'LM', '', A_MATR_CODE,
										  '', 0, 0, '', '', 'NORMAL', V_LOT_STATE_DET, A_WORK_QTY - A_BAD_QTY, 0, 'TB_COATING_WORK', V_WORK_KEY,
										  A_ORDER_KEY, A_PROG_CODE, V_PROG_SEQ, V_PROG_KIND, '', V_ITEM_KIND, 'PROG', V_PROD_UNIT_WET, V_MATR_UNIT_WET,
										  '', 0, 0, V_PROG_KIND, 'Y', A_SYS_ID, A_SYS_EMP_NO, V_LOT_NO, N_RETURN, V_RETURN);
		if N_RETURN = -1 then
			leave PROC_BODY;
		end if;										 
	end if;	

	select WARE_CODE, WARE_CODE_PROC 
	into V_WARE_CODE, V_WARE_CODE_PROC
	from   dept_code
	where  DEPT_CODE = A_WORK_DEPT;

	set V_SUBUL_KEY = concat('TB_COATING_WORK-', V_WORK_KEY);

	-- 수불처리? 공정은 Z00으로 처리한다고 한다
	-- 코팅실적은 출고로 처리한다. WARE_CODE에 출고, WARE_CODE_PROC 에 입고
	-- dept_code는 work_dept 기준으로 적용한다 <- ??
	-- 실적 DET -> 코팅 후 각자의 LOT 번호를 부여한다. 
	-- 	 MST는 총 갯수로 입고, DET는 각자 1개씩 출고

	/*
	-- 수불생성 (공정중 실적 내역은 선점 처리 안함) 최종공정일때만 선점처리함 
	if V_FINAL_PROG_YN = 'Y' then -- 최종공정일때 
		# 제품입고수불(최종공정)
		set V_IO_GUBN = 169917; -- 생산입고(최종공정)
		set V_PROG_CODE = 100; -- 재고상태
		call SP_SUBUL_CREATE(
			A_COMP_ID, V_SUBUL_KEY, 'INSERT', V_SET_DATE, '1', V_WARE_CODE, V_ITEM_KIND, A_ITEM_CODE, A_LOT_NO, V_PROG_CODE, 
			V_IO_GUBN, A_WORK_QTY - A_BAD_QTY, 0, 0, 'TB_COATING_WORK', V_WORK_KEY, 'Y', 1, '', '', 
			'N', V_SET_DATE, A_ORDER_KEY, 'N', 'Y', 'Y', 
			A_SYS_ID, A_SYS_EMP_NO, N_RETURN, V_RETURN );
		if N_RETURN = -1 then
			leave PROC_BODY;
		end if;			
	else
		# 재공입고수불(현재공정)
		set V_IO_GUBN = 169911; -- 생산공정입고

		call SP_SUBUL_CREATE(
			A_COMP_ID, V_SUBUL_KEY, 'INSERT', V_SET_DATE, '1', V_WARE_CODE_PROC, V_ITEM_KIND, A_ITEM_CODE, A_LOT_NO, A_PROG_CODE, 
			V_IO_GUBN, A_WORK_QTY - A_BAD_QTY, 0, 0, 'TB_COATING_WORK', V_WORK_KEY, 'Y', 1, '', '', 
			'N', V_SET_DATE, A_ORDER_KEY, 'N', 'Y', 'Y', 
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
			A_COMP_ID, V_SUBUL_PRE_KEY, 'INSERT', V_SET_DATE, '2', V_WARE_CODE_PROC, V_ITEM_KIND, A_ITEM_CODE, A_LOT_NO, A_PROG_CODE_PRE, 
			V_IO_GUBN, A_WORK_QTY, 0, 0, 'TB_COATING_WORK', V_WORK_KEY, 'Y', 1, '', '', 
			'N', V_SET_DATE, A_ORDER_KEY, 'N', 'Y', 'Y', 
			A_SYS_ID, A_SYS_EMP_NO, N_RETURN, V_RETURN );
		if N_RETURN = -1 then
			leave PROC_BODY;
		end if;			
	end if;
	*/

  	update TB_COATING_PLAN_DET
  	   set WORK_QTY = WORK_QTY + (A_WORK_QTY - A_BAD_QTY)
  	 where COMP_ID = A_COMP_ID
  	   and WORK_PLAN_KEY = A_WORK_PLAN_KEY
  	;
  
	insert into TB_COATING_WORK (
		COMP_ID, WORK_LINE, SET_DATE, SET_SEQ, SET_NO,
		WORK_KEY, WORK_DATE, MATR_CODE, PROG_CODE, EQUI_CODE,
		ORDER_KEY, WORK_PLAN_KEY, LOT_NO, PLAN_QTY, WORK_QTY,
		BAD_QTY, START_TIME, END_TIME, SHIP_INFO, WORK_DEPT,
		WORK_EMP, WARE_CODE, RMK,
		SYS_EMP_NO, SYS_ID, SYS_DATE
	) values (
		A_COMP_ID, A_WORK_LINE, V_SET_DATE, V_SET_SEQ, V_SET_NO,
		A_WORK_KEY, A_WORK_DATE, A_MATR_CODE, A_PROG_CODE, A_EQUI_CODE,
		A_ORDER_KEY, A_WORK_PLAN_KEY, A_LOT_NO, A_PLAN_QTY, A_WORK_QTY,
		A_BAD_QTY, SYSDATE(), SYSDATE(), A_SHIP_INFO, A_WORK_DEPT,
		A_WORK_EMP, A_WARE_CODE, A_RMK,
		A_SYS_EMP_NO, A_SYS_ID, SYSDATE()
	);
							
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
END