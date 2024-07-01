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
	declare V_ITEM_KIND			bigint;
	declare V_IO_GUBN			bigint;
	declare V_SEQ			VARCHAR(3);
	declare V_LOT_NO		VARCHAR(30);
	declare V_LOT_NO_NEW	VARCHAR(30);
	declare V_PROG_CODE		bigint;
	declare V_PROG_KIND		bigint;
	declare V_LOT_STATE_DET		bigint;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 

  	
  	set V_SET_DATE = date_format(A_WORK_DATE,'%Y%m%d');
   

	-- 240617 문의결과
	-- 기존 LOT_NO에 세자리 순번 추가하여야 한다.
	set V_SEQ = (select
					   LPAD(IFNULL(MAX(RIGHT(LOT_NO, 3)), 0) + 1, 3, '0')
				 from TB_COATING_WORK_DET
				 where COMP_ID = A_COMP_ID
				   and WORK_KEY = A_WORK_KEY
				   and LOT_NO_PRE = A_LOT_NO
				);

	set V_LOT_NO_NEW = CONCAT(A_LOT_NO, V_SEQ);

	SET V_PROG_KIND = 40879; -- cfg.code.lot.init LOT생성사유 공정생산  
	set V_ITEM_KIND = 145919; -- cfg.item.M (원자재)
	set V_LOT_STATE_DET = 40809; -- cfg.code.lot.status 정상  
	set V_PROG_CODE = 1703; -- 원자재코팅 공정 
	
	
	call PKG_LOT$CREATE_ITEM_LOT_IUD ('INSERT', A_COMP_ID, V_LOT_NO_NEW, '', '', V_SET_DATE, 'LM', '', A_MATR_CODE,
									  '', 0, 0, '', A_LOT_NO, 'NORMAL', V_LOT_STATE_DET, 0, 0, 'TB_COATING_WORK_DET', A_WORK_KEY,
									  null, V_PROG_CODE, 0, V_PROG_KIND, '', V_ITEM_KIND, 'NEW', null, null,
									  '', 0, 0, V_PROG_KIND, 'Y', '', A_SYS_ID, A_SYS_EMP_NO, V_LOT_NO, N_RETURN, V_RETURN);
	if N_RETURN = -1 then
		leave PROC_BODY;
	end if;
	
	set V_SUBUL_KEY = concat('TB_COATING_WORK_DET-', A_WORK_KEY, V_LOT_NO);

	-- 코팅실적은 출고로 처리하여 수불한다. (1개씩 처리)
	-- 재고의 WARE_CODE 로부터 출고처리한다.
		
	# 원자재공정투입입고수불
	set V_IO_GUBN = (select DATA_ID
					 from SYS_DATA
					 where FULL_PATH = 'cfg.com.io.mat.in.proc'); -- 생산공정투입 
					 
	-- DET에 입고
	call SP_SUBUL_CREATE(
		A_COMP_ID, V_SUBUL_KEY, 'INSERT', V_SET_DATE, '1', A_WARE_CODE, V_ITEM_KIND, A_MATR_CODE, V_LOT_NO, V_PROG_CODE, 
		V_IO_GUBN, 1, 0, 0, 'TB_COATING_WORK_DET', concat(A_WORK_KEY, V_LOT_NO), 'Y', 1, '', '', 
		'N', V_SET_DATE, '', 'N', 'Y', 'Y', 
		A_SYS_ID, A_SYS_EMP_NO, N_RETURN, V_RETURN );
	if N_RETURN = -1 then
		leave PROC_BODY;
	end if;		

  	insert into TB_COATING_WORK_DET (
  		COMP_ID, WORK_LINE, WORK_KEY, WORK_DATE, MATR_CODE,
  		PROG_CODE, LOT_NO_PRE, LOT_NO, WORK_QTY, WORK_DEPT, WARE_CODE,
  		RMK,
  		SYS_EMP_NO, SYS_ID, SYS_DATE
  	) values (
  		A_COMP_ID, A_WORK_LINE, A_WORK_KEY, DATE_FORMAT(A_WORK_DATE, '%Y%m%d'), A_MATR_CODE,
  		A_PROG_CODE, A_LOT_NO, V_LOT_NO, A_WORK_QTY, A_WORK_DEPT, A_WARE_CODE,
  		A_RMK,
  		A_SYS_EMP_NO, A_SYS_ID, SYSDATE()
  	)
  	;
							
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
END