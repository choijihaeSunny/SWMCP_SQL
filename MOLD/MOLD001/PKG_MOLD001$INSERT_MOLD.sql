CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD001$INSERT_MOLD`(		
	IN A_MOLD_CODE varchar(20),
	IN A_CLASS1 bigint(20),
	IN A_CLASS2 bigint(20),
	IN A_CLASS_SEQ varchar(4),
	IN A_MOLD_NAME varchar(50),
	IN A_MOLD_SPEC varchar(50),
	IN A_LOT_YN bigint(20),
	IN A_STOCK_SAFE decimal(10, 0),
	IN A_CUST_CODE varchar(10),
	IN A_ITEM_UNIT decimal(10, 0),
	IN A_USE_YN varchar(1),
	IN A_RMK varchar(100),
	IN A_CODE_PRE varchar(30),
	IN A_WARE_POS varchar(10),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	DECLARE V_CLASS1 VARCHAR(20);
	DECLARE V_CLASS2 VARCHAR(20);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
    SET V_CLASS1 = (select CODE
    			    from sys_data
    			    where path = 'cfg.mold.class1'
    			      and data_id = A_CLASS1);
    			     
    SET V_CLASS2 = (select CODE
    				from sys_data
    				where path = CONCAT('cfg.mold.class1.', V_CLASS1)
    				  and data_id = A_CLASS2);
  
    SET A_MOLD_CODE := CONCAT('M', LPAD(V_CLASS1, 2, '0'), LPAD(V_CLASS2, 3, '0'), LPAD(A_CLASS_SEQ, 4, '0'));
   
  	
    INSERT INTO TB_MOLD (
    	MOLD_CODE,
    	CLASS1,
    	CLASS2,
    	CLASS_SEQ,
    	MOLD_NAME,
    	MOLD_SPEC,
    	LOT_YN,
    	STOCK_SAFE,
    	CUST_CODE,
    	ITEM_UNIT,
    	USE_YN,
    	RMK,
    	CODE_PRE,
    	WARE_POS
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
    	A_MOLD_CODE,
    	A_CLASS1,
    	A_CLASS2,
    	LPAD(A_CLASS_SEQ, 4, '0'),
    	A_MOLD_NAME,
    	A_MOLD_SPEC,
    	A_LOT_YN,
    	A_STOCK_SAFE,
    	A_CUST_CODE,
    	A_ITEM_UNIT,
    	A_USE_YN,
    	A_RMK,
    	A_CODE_PRE,
    	A_WARE_POS
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end