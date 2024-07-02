CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE026$INSERT_OUT_MST`(	
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE DATETIME,
	IN A_SET_SEQ varchar(4),
	INOUT A_OUT_MST_KEY varchar(30),
	IN A_OUT_DATE DATETIME,
	IN A_CUST_CODE varchar(10),
	IN A_EMP_NO varchar(10),
	IN A_DEPT_CODE varchar(10),
	IN A_CURR_UNIT bigint(20),
	IN A_EX_RATE decimal(20,5),
	IN A_PJ_NO varchar(30),
	IN A_PJ_NAME varchar(50),
	IN A_SHIP_INFO varchar(30),
	IN A_SALES_TYPE bigint(20),
	IN A_DELI_PLACE varchar(100),
	IN A_SALES_KIND bigint(20),
	IN A_CUST_LOCATION varchar(100),
	IN A_PACK_SPEC varchar(100),
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
  
  	SET A_OUT_MST_KEY = concat('GO', date_format(A_SET_DATE, '%y%m'), LPAD(A_SET_SEQ, 4, '0'));
  
  
  	INSERT INTO tb_out_mst 
	  		(COMP_ID,
			SET_DATE,
			SET_SEQ,
			OUT_MST_KEY,
			OUT_DATE,
			CUST_CODE,
			EMP_NO,
			DEPT_CODE,
			CURR_UNIT,
			EX_RATE,
			PJ_NO,
			PJ_NAME,
			SHIP_INFO,
			SALES_TYPE,
			DELI_PLACE,
			SALES_KIND,
			CUST_LOCATION,
			PACK_SPEC,
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
			A_OUT_MST_KEY,
			date_format(A_OUT_DATE,'%Y%m%d'),
			A_CUST_CODE,
			A_EMP_NO,
			A_DEPT_CODE,
			A_CURR_UNIT,
			A_EX_RATE,
			A_PJ_NO,
			A_PJ_NAME,
			A_SHIP_INFO,
			A_SALES_TYPE,
			A_DELI_PLACE,
			A_SALES_KIND,
			A_CUST_LOCATION,
			A_PACK_SPEC,
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