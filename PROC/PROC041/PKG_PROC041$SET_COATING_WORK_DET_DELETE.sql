CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROC041$SET_COATING_WORK_DET_DELETE`(	
	IN A_COMP_ID varchar(10), 
	IN A_WORK_LINE varchar(10), 
	IN A_WORK_KEY varchar(30), 
	IN A_WORK_DATE DATETIME, 
	IN A_MATR_CODE varchar(30),
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
	declare V_WORK_QTY		DECIMAL(16,4);
	declare V_WARE_CODE			bigint;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

--	select CODE into V_ITEM_KIND from SYS_DATA where DATA_ID = A_ITEM_KIND;
	
	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 

  	set V_SET_DATE = date_format(A_SET_DATE,'%Y%m%d');
    
	set V_ITEM_KIND = 145919; -- cfg.item.M (원자재)
	set V_SUBUL_KEY = concat('TB_COATING_WORK_DET-', A_WORK_KEY, A_LOT_NO);

	select WORK_QTY, WARE_CODE 
	into V_WORK_QTY, V_WARE_CODE
	from   TB_COATING_WORK_DET 
	where  COMP_ID = A_COMP_ID 
	  and WORK_KEY = A_WORK_KEY 
	  and LOT_NO = A_LOT_NO
	;
	
	/*
	# 원자재공정투입출고수불
	set V_IO_GUBN = 34304; -- 생산공정투입
	call SP_SUBUL_CREATE(
		A_COMP_ID, V_SUBUL_KEY, 'DELETE', V_SET_DATE, '2', V_WARE_CODE, V_ITEM_KIND, A_MATR_CODE, A_LOT_NO, A_PROG_CODE, 
		V_IO_GUBN, V_WORK_QTY, 0, 0, 'TB_COATING_WORK_DET', concat(A_WORK_KEY, A_LOT_NO), 'Y', 1, '', '', 
		'N', V_SET_DATE, '', 'N', 'Y', 'Y', 
		A_SYS_ID, A_SYS_EMP_NO, N_RETURN, V_RETURN );
	if N_RETURN = -1 then
		leave PROC_BODY;
	end if;			
	*/

	delete FROM TB_COATING_WORK_DET 
	 where  COMP_ID = A_COMP_ID 
	   and WORK_KEY = A_WORK_KEY 
	   and LOT_NO = A_LOT_NO
	;		   
		
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
END