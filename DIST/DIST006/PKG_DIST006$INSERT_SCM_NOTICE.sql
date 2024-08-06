CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST006$INSERT_SCM_NOTICE`(		
	IN A_COMP_ID VARCHAR(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_NOTICE_GUBN VARCHAR(3),
	IN A_NOTICE_TITLE VARCHAR(50),
	IN A_NOTICE_COMMENT VARCHAR(1000),
	IN A_NOTICE_EMP_NO VARCHAR(10),
  	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_SEQ VARCHAR(4);
	declare V_SET_DATE VARCHAR(8);
	declare V_NOTICE_MST_KEY VARCHAR(30);
	
	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.';
  
    set V_SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d');
   
    set V_SET_SEQ = (select LPAD(IFNULL(MAX(SET_SEQ), 0) + 1, 4, 0)
   					 from TB_SCM_NOTICE
   					 where COMP_ID = A_COMP_ID 
   					   and SET_DATE = V_SET_DATE);
   					  
   	set V_NOTICE_MST_KEY = CONCAT('NO', V_SET_DATE, V_SET_SEQ);
  
  	insert into TB_SCM_NOTICE (
  		COMP_ID,
  		SET_DATE,
  		SET_SEQ,
  		NOTICE_MST_KEY,
  		NOTICE_GUBN,
  		NOTICE_TITLE,
  		NOTICE_COMMENT,
  		NOTICE_EMP_NO,
  		SYS_ID,
  		SYS_EMP_NO,
  		SYS_DT
  	) values (
  		A_COMP_ID,
  		V_SET_DATE,
  		V_SET_SEQ,
  		V_NOTICE_MST_KEY,
  		A_NOTICE_GUBN,
  		A_NOTICE_TITLE,
  		A_NOTICE_COMMENT,
  		A_NOTICE_EMP_NO
  		,A_SYS_ID
	    ,A_SYS_EMP_NO
	    ,SYSDATE()
  	)
  	;
		
  	IF ROW_COUNT() = 0 THEN
		SET N_RETURN = -1;
		SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
	END IF;
  	
end