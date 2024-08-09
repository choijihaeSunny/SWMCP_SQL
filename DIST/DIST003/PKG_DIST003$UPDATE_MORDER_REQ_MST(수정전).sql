CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST003$UPDATE_MORDER_REQ_MST`(	
	IN A_COMP_ID varchar(10),
	IN A_MORDER_REQ_MST_KEY varchar(30),
	IN A_ORDER_DATE DATETIME,
	IN A_ITEM_CODE varchar(30),
	IN A_REQ_QTY decimal(20,0),
	IN A_DELI_DATE DATETIME,
	IN A_EMP_NO varchar(10),
	IN A_DEPT_CODE varchar(10),
	IN A_SHIP_INFO varchar(30),
	IN A_PJ_NO varchar(30),
	IN A_PJ_NAME varchar(50),
	IN A_MORDER_QTY decimal(20,0),
	IN A_ORDER_KEY varchar(30),
	IN A_PRE_STOCK_KIND bigint(20),
	IN A_END_YN varchar(1),
	IN A_END_DATE DATETIME,
	IN A_END_EMP_NO varchar(10),
	IN A_RMK varchar(100),
	IN A_TEMP1 varchar(10),
	IN A_TEMP2 varchar(10),
	IN A_TEMP3 varchar(10),
	IN A_TEMP4 varchar(10),
	IN A_TEMP5 varchar(10),
	IN A_SYS_ID decimal(10,0),
	IN A_SYS_EMP_NO varchar(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	SET N_RETURN = 0;
  	SET V_RETURN = '수정되었습니다.'; 
  	
  	UPDATE tb_morder_req_mst set
  			ORDER_DATE = date_format(A_ORDER_DATE,'%Y%m%d'),
			#ITEM_CODE = A_ITEM_CODE,
			REQ_QTY = A_REQ_QTY,
			DELI_DATE = date_format(A_DELI_DATE,'%Y%m%d'),
			SHIP_INFO = A_SHIP_INFO,
			PJ_NO = A_PJ_NO,
			PJ_NAME = A_PJ_NAME,
			MORDER_QTY = A_MORDER_QTY,
			PRE_STOCK_KIND = A_PRE_STOCK_KIND,
			RMK = A_RMK,
			UPD_ID = A_SYS_ID,
			UPD_EMP_NO = A_SYS_EMP_NO,
			UPD_DT = SYSDATE()
    	where COMP_ID = A_COMP_ID
    		and MORDER_REQ_MST_KEY = A_MORDER_REQ_MST_KEY;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '수정에 실패하였습니다.'; 
  	END IF;  
  
end