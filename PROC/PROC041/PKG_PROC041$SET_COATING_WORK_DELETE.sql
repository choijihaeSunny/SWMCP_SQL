CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROC041$SET_COATING_WORK_DELETE`(	
	in A_COMP_ID		varchar(10),
	in A_WORK_LINE		varchar(10),
	in A_SET_DATE		DATETIME,
	in A_SET_SEQ		VARCHAR(3),
	in A_SET_NO			VARCHAR(3),
	in A_WORK_KEY		VARCHAR(30),
	in A_WORK_DATE		DATETIME,
	in A_MATR_CODE		VARCHAR(30),
	in A_ORDER_KEY		VARCHAR(30),
	in A_LOT_NO			VARCHAR(30),
	in A_WORK_EMP		VARCHAR(10),
	in A_RMK			VARCHAR(100),
	IN A_SYS_ID decimal(10,0), 
	IN A_SYS_EMP_NO varchar(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
PROC_BODY : begin
	declare V_WORK_KEY 		VARCHAR(50);
	declare V_SET_DATE		VARCHAR(8);
	declare V_SUBUL_KEY		VARCHAR(100);
	declare V_SUBUL_ORDER_KEY	VARCHAR(100);
	declare	V_SUBUL_PRE_KEY	VARCHAR(100);
	declare V_WORK_PLAN_KEY VARCHAR(50);
	declare V_WORK_QTY		DECIMAL(16,4);
	declare V_BAD_QTY		DECIMAL(16,4);
	declare V_LOT_NO		VARCHAR(30);
	declare V_PROG_KIND		bigint;
	declare V_ITEM_KIND		bigint;
	declare V_LOT_STATE_DET		bigint;
	declare V_WARE_CODE			bigint;
	declare V_PROG_CODE			bigint;
	declare V_IO_GUBN			bigint;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

--	select CODE into V_ITEM_KIND from SYS_DATA where DATA_ID = A_ITEM_KIND;
	
	SET N_RETURN = 0;
  	SET V_RETURN = '삭제되었습니다.'; 

  	set V_SET_DATE = date_format(A_SET_DATE,'%Y%m%d');
  
	SET V_PROG_KIND = 40879; -- cfg.code.lot.init LOT생성사유 공정생산  
	set V_ITEM_KIND = 145919; -- cfg.item.M (원자재)
	set V_LOT_STATE_DET = 40809; -- cfg.code.lot.status 정상 
   	
	select WORK_PLAN_KEY, WORK_QTY, WORK_KEY, BAD_QTY, PROG_CODE, WARE_CODE
	into V_WORK_PLAN_KEY, V_WORK_QTY, V_WORK_KEY, V_BAD_QTY, V_PROG_CODE, V_WARE_CODE
	from   TB_COATING_WORK  
	where  COMP_ID = A_COMP_ID 
	and WORK_KEY = A_WORK_KEY;
	

	set V_SUBUL_KEY = concat('TB_COATING_WORK-', A_WORK_KEY); #  입고수불 삭제
	
	set V_IO_GUBN = (select DATA_ID
					 from SYS_DATA
					 where FULL_PATH = 'cfg.com.io.mat.out.proc'); -- 생산투입 
	set V_SUBUL_PRE_KEY = CONCAT(V_SUBUL_KEY, 'PRE');  
	call SP_SUBUL_CREATE(
			A_COMP_ID, V_SUBUL_PRE_KEY, 'DELETE', V_SET_DATE, '2', V_WARE_CODE, V_ITEM_KIND, A_MATR_CODE, A_LOT_NO, V_PROG_CODE, 
			V_IO_GUBN, V_WORK_QTY, 0, 0, 'TB_COATING_WORK', V_WORK_KEY, 'Y', 1, '', '', 
			'N', V_SET_DATE, A_ORDER_KEY, 'N', 'Y', 'Y', 
			A_SYS_ID, A_SYS_EMP_NO, N_RETURN, V_RETURN );
	if N_RETURN = -1 then
		leave PROC_BODY;
	end if;	
	

	update TB_COATING_PLAN_DET 
	set    WORK_QTY = WORK_QTY - (V_WORK_QTY - V_BAD_QTY)
	where  COMP_ID = A_COMP_ID 
	  and WORK_PLAN_KEY = V_WORK_PLAN_KEY
	;

	delete from TB_COATING_WORK 
	where  COMP_ID = A_COMP_ID 
	and WORK_KEY = A_WORK_KEY;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
END