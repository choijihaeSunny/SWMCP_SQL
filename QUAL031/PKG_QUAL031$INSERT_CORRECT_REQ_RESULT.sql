CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_QUAL031$INSERT_CORRECT_REQ_RESULT`(		
	IN A_COMP_ID varchar(10),
	IN A_REQ_DATE TIMESTAMP,
	IN A_REQ_SEQ VARCHAR(3),
	IN A_REQ_KEY VARCHAR(20),
	IN A_STATUS_DIV BIGINT(20),
	IN A_REQ_EMP_NO VARCHAR(10),
	IN A_REQ_DEPT VARCHAR(50),
	IN A_REC_DEPT VARCHAR(10),
	IN A_REPLY_DATE TIMESTAMP,
	IN A_TEST_DATE TIMESTAMP,
	IN A_REQ_RMK VARCHAR(100),
	IN A_STATUS_NOW VARCHAR(200),
	IN A_CORRECT_PLAN VARCHAR(200),
	IN A_REQ_CAUSE VARCHAR(200),
	IN A_REQ_PLAN VARCHAR(200),
	IN A_IMP_DATE TIMESTAMP,
	IN A_ACT_RESULT BIGINT(20),
	IN A_CONTINUE_PLAN VARCHAR(200),
	IN A_ACT_EFFECT BIGINT(20),
	IN A_ACT_EFFECT_DETAIL VARCHAR(200),
	IN A_ACT_EFFECT_MANAGE BIGINT(20),
	IN A_REPLY_EMP_NO VARCHAR(10),
	IN A_CONF_EMP_NO VARCHAR(20),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
    set A_REQ_KEY := concat(DATE_FORMAT(A_REQ_DATE, '%Y%m%d'), LPAD(A_REQ_SEQ, 3, '0')) ;
  
    insert into TB_CORRECT_REQ_RESULT (
     	  COMP_ID,
    	  REQ_DATE,
		  REQ_SEQ,
		  REQ_KEY,
		  STATUS_DIV,
		  REQ_EMP_NO,
		  REQ_DEPT,
		  REC_DEPT,
		  REPLY_DATE,
		  TEST_DATE,
		  REQ_RMK,
		  STATUS_NOW,
		  CORRECT_PLAN,
		  REQ_CAUSE,
		  REQ_PLAN,
		  IMP_DATE,
		  ACT_RESULT,
		  CONTINUE_PLAN,
		  ACT_EFFECT,
		  ACT_EFFECT_DETAIL,
		  ACT_EFFECT_MANAGE,
		  REPLY_EMP_NO,
		  CONF_EMP_NO
		  ,SYS_EMP_NO
    	  ,SYS_ID
    	  ,SYS_DATE
    ) values (
    	  A_COMP_ID,
    	  DATE_FORMAT(A_REQ_DATE, '%Y%m%d'),
		  A_REQ_SEQ,
		  A_REQ_KEY,
		  A_STATUS_DIV,
		  A_REQ_EMP_NO,
		  A_REQ_DEPT,
		  A_REC_DEPT,
		  DATE_FORMAT(A_REPLY_DATE, '%Y%m%d'),
		  DATE_FORMAT(A_TEST_DATE, '%Y%m%d'),
		  A_REQ_RMK,
		  A_STATUS_NOW,
		  A_CORRECT_PLAN,
		  A_REQ_CAUSE,
		  A_REQ_PLAN,
		  DATE_FORMAT(A_IMP_DATE, '%Y%m%d'),
		  A_ACT_RESULT,
		  A_CONTINUE_PLAN,
		  A_ACT_EFFECT,
		  A_ACT_EFFECT_DETAIL,
		  A_ACT_EFFECT_MANAGE,
		  A_REPLY_EMP_NO,
		  A_CONF_EMP_NO
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