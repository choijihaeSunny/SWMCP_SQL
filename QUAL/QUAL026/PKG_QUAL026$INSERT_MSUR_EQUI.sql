CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_QUAL026$INSERT_MSUR_EQUI`(		
	IN A_COMP_ID varchar(10),
	INOUT A_EQUI_CODE varchar(20),
	IN A_CLASS1 bigint(20),
	IN A_CLASS2 bigint(20),
	IN A_TEMP_SEQ varchar(3),
	IN A_EQUI_NAME varchar(50),
	IN A_EQUI_SPEC varchar(200),
	IN A_EQUI_NUM varchar(20),
	IN A_MAKE_COMP varchar(50),
	IN A_MODEL_NAME varchar(50),
	IN A_BUY_AMT decimal(16, 4),
	IN A_BUY_COMP varchar(50),
	IN A_BUY_DATE timestamp,
	IN A_USE_DEPT varchar(10),
	IN A_ETC_RMK varchar(20),
	IN A_BUY_POST_NO varchar(10),
	IN A_BUY_ADDRESS varchar(100),
	IN A_BUY_PHONE varchar(20),
	IN A_RES_STATUS bigint(20),
	IN A_USE_EMP_NO varchar(20),
	IN A_BUY_EMAIL varchar(50),
	IN A_PREV_EQUI_CODE varchar(20),
	IN A_FILE_NAME varchar(100),
	IN A_REAL_FILE_NAME varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
PROC_BODY : begin
	
	DECLARE V_CLASS1 VARCHAR(20);
	DECLARE V_CLASS2 VARCHAR(20);

	declare V_CNT INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
    SET V_CLASS1 = (select CODE
    			    from sys_data
    			    where path = 'cfg.qual.equi.class1'
    			      and data_id = A_CLASS1);
    			     
    SET V_CLASS2 = (select CODE
    				from sys_data
    				where path = CONCAT('cfg.qual.equi.class1.', V_CLASS1)
    				  and data_id = A_CLASS2);
  
    SET A_EQUI_CODE := CONCAT(LPAD(V_CLASS1, 2, '0'), LPAD(V_CLASS2, 2, '0'), LPAD(A_TEMP_SEQ, 3, '0'));
   
    
    set V_CNT = (select COUNT(*)
   				 from TB_MSUR_EQUI
   				 where EQUI_CODE = A_EQUI_CODE);
   
   	if V_CNT > 0 then
   		SET N_RETURN = -1;
  		SET V_RETURN = '순번 값이 중복됩니다. 다시 확인하여 주십시오.'; 
  		leave PROC_BODY;
   	end if;
  	
    INSERT INTO TB_MSUR_EQUI (
    	COMP_ID,
    	EQUI_CODE,
    	CLASS1,
    	CLASS2,
    	TEMP_SEQ,
    	EQUI_NAME,
    	EQUI_SPEC,
    	EQUI_NUM,
    	MAKE_COMP,
    	MODEL_NAME,
    	BUY_AMT,
    	BUY_COMP,
    	BUY_DATE,
    	USE_DEPT,
    	ETC_RMK,
    	BUY_POST_NO,
    	BUY_ADDRESS,
    	BUY_PHONE,
    	RES_STATUS,
    	USE_EMP_NO,
    	BUY_EMAIL,
    	PREV_EQUI_CODE,
    	FILE_NAME,
    	REAL_FILE_NAME
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
    	A_COMP_ID,
    	A_EQUI_CODE,
    	A_CLASS1,
    	A_CLASS2,
    	LPAD(A_TEMP_SEQ, 3, '0'),
    	A_EQUI_NAME,
    	A_EQUI_SPEC,
    	A_EQUI_NUM,
    	A_MAKE_COMP,
    	A_MODEL_NAME,
    	A_BUY_AMT,
    	A_BUY_COMP,
    	DATE_FORMAT(A_BUY_DATE, '%Y%m%d'),
    	A_USE_DEPT,
    	A_ETC_RMK,
    	A_BUY_POST_NO,
    	A_BUY_ADDRESS,
    	A_BUY_PHONE,
    	A_RES_STATUS,
    	A_USE_EMP_NO,
    	A_BUY_EMAIL,
    	A_PREV_EQUI_CODE,
    	A_FILE_NAME,
    	A_REAL_FILE_NAME
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