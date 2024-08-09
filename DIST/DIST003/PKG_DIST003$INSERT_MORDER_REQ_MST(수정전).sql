CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST003$INSERT_MORDER_REQ_MST`(	
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE DATETIME,
	IN A_SET_SEQ varchar(4),
	IN A_SET_NO varchar(4),
	INOUT A_MORDER_REQ_MST_KEY varchar(30),
	IN A_MORDER_KIND bigint(20),
	IN A_ORDER_DATE DATETIME,
	IN A_ITEM_CODE varchar(30),
	IN A_REQ_QTY decimal(20,0),
	IN A_DELI_DATE DATETIME,
	IN A_EMP_NO varchar(10),
	IN A_DEPT_CODE varchar(10),
	IN A_WARE_CODE bigint(20),
	IN A_SHIP_INFO varchar(30),
	IN A_PJ_NO varchar(30),
	IN A_PJ_NAME varchar(50),
	IN A_MORDER_QTY decimal(20,0),
	IN A_ORDER_KEY varchar(30),
	IN A_DET_SEQ varchar(2),
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
	declare V_SET_NO VARCHAR(4);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	select TRIM(LPAD(IFNULL(MAX(SET_NO),0) + 1, 4, '0')) INTO V_SET_NO from tb_morder_req_mst 
  		where COMP_ID = A_COMP_ID 
  			and SET_DATE = date_format(A_SET_DATE,'%Y%m%d')
  			and SET_SEQ = LPAD(A_SET_SEQ, 4, '0')
  			and MORDER_REQ_MST_KEY like 'PR%';
  	
  	set A_MORDER_REQ_MST_KEY = concat('PR', date_format(A_SET_DATE,'%y%m'), LPAD(A_SET_SEQ, 4, '0'), V_SET_NO);
  		
    INSERT INTO tb_morder_req_mst(COMP_ID,
							SET_DATE,
							SET_SEQ,
							SET_NO,
							MORDER_REQ_MST_KEY,
							MORDER_KIND,
							ORDER_DATE,
							ITEM_CODE,
							REQ_QTY,
							DELI_DATE,
							EMP_NO,
							DEPT_CODE,
							WARE_CODE,
							SHIP_INFO,
							PJ_NO,
							PJ_NAME,
							MORDER_QTY,
							ORDER_KEY,
							DET_SEQ,
							PRE_STOCK_KIND,
							RMK,
							SYS_ID,
							SYS_EMP_NO,
							SYS_DT,
							UPD_ID,
							UPD_EMP_NO,
							UPD_DT)
                     VALUES(A_COMP_ID,
							date_format(A_SET_DATE,'%Y%m%d'),
							LPAD(A_SET_SEQ, 4, '0'),
							V_SET_NO,
							A_MORDER_REQ_MST_KEY,
							A_MORDER_KIND,
							date_format(A_ORDER_DATE,'%Y%m%d'),
							A_ITEM_CODE,
							A_REQ_QTY,
							date_format(A_DELI_DATE,'%Y%m%d'),
							A_EMP_NO,
							A_DEPT_CODE,
							A_WARE_CODE,
							A_SHIP_INFO,
							A_PJ_NO,
							A_PJ_NAME,
							A_MORDER_QTY,
							A_ORDER_KEY,
							A_DET_SEQ,
							A_PRE_STOCK_KIND,
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
  
  	/*if A_ORDER_KEY is not null and A_ORDER_KEY != '' then
  	
  		update tb_order_det set
  			MORDER_QTY = Nvl(MORDER_QTY, 0) + A_REQ_QTY
  		where COMP_ID = A_COMP_ID
  			and ORDER_KEY = A_ORDER_KEY;
  	
  	end if;*/
  
end