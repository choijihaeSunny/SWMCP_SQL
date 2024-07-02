CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE026$INSERT_OUT_DET`(	
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE DATETIME,
	IN A_SET_SEQ varchar(4),
	INOUT A_SET_NO varchar(4),
	IN A_OUT_MST_KEY varchar(30),
	IN A_OUT_KEY varchar(30),
	IN A_OUT_DATE DATETIME,
	IN A_ITEM_CODE varchar(30),
	IN A_QTY decimal(20,4),
	IN A_COST decimal(20,4),
	IN A_AMT decimal(20,4),
	IN A_REQ_KIND bigint(20),
	IN A_DELI_DATE DATETIME,
	IN A_CUST_REQ_RMK varchar(100),
	IN A_PACK_SPEC varchar(100),
	IN A_CUST_ITEM_CODE varchar(30),
	IN A_CUST_ORDER_NO varchar(30),
	IN A_ORDER_KEY varchar(30),
	IN A_OUT_REQ_KEY varchar(30),
	IN A_RMK varchar(100),
	IN A_SYS_ID decimal(10,0),
	IN A_SYS_EMP_NO varchar(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	select TRIM(LPAD(IFNULL(MAX(SET_NO),0) + 1, 4, '0')) INTO A_SET_NO from tb_out_det 
  		where COMP_ID = A_COMP_ID 
  			and OUT_MST_KEY = A_OUT_MST_KEY;
  
  	INSERT INTO tb_out_det 
	  		(COMP_ID,
			SET_DATE,
			SET_SEQ,
			SET_NO,
			OUT_MST_KEY,
			OUT_KEY,
			OUT_DATE,
			ITEM_CODE,
			QTY,
			COST,
			AMT,
			REQ_KIND,
			DELI_DATE,
			CUST_REQ_RMK,
			PACK_SPEC,
			CUST_ITEM_CODE,
			CUST_ORDER_NO,
			OUT_CONFIRM,
			ORDER_KEY,
			OUT_REQ_KEY,
			RMK,
			SYS_ID,
			SYS_EMP_NO,
			SYS_DT,
			UPD_ID,
			UPD_EMP_NO,
			UPD_DT)
     VALUES(A_COMP_ID,
			date_format(A_SET_DATE,'%Y%m%d'),
			A_SET_SEQ,
			A_SET_NO,
			A_OUT_MST_KEY,
			concat(A_OUT_MST_KEY, A_SET_NO),
			date_format(A_OUT_DATE,'%Y%m%d'),
			A_ITEM_CODE,
			A_QTY,
			A_COST,
			A_AMT,
			A_REQ_KIND,
			date_format(A_DELI_DATE,'%Y%m%d'),
			A_CUST_REQ_RMK,
			A_PACK_SPEC,
			A_CUST_ITEM_CODE,
			A_CUST_ORDER_NO,
			'1',
			A_ORDER_KEY,
			A_OUT_REQ_KEY,
			A_RMK,
			A_SYS_ID,
			A_SYS_EMP_NO,
			SYSDATE(),
			A_SYS_ID,
			A_SYS_EMP_NO,
			SYSDATE());
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end