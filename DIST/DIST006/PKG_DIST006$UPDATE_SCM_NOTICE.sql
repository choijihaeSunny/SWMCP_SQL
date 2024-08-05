CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST006$UPDATE_SCM_NOTICE`(		
	IN A_COMP_ID VARCHAR(10),
	IN A_NOTICE_MST_KEY VARCHAR(30),
	IN A_NOTICE_GUBN VARCHAR(3),
	IN A_NOTICE_TITLE VARCHAR(50),
	IN A_NOTICE_COMMENT VARCHAR(500),
	IN A_NOTICE_EMP_NO VARCHAR(10),
  	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.';
  
  
  	update TB_SCM_NOTICE
  		set NOTICE_GUBN = A_NOTICE_GUBN,
  		    NOTICE_TITLE = A_NOTICE_TITLE,
  		    NOTICE_COMMENT = A_NOTICE_COMMENT,
  		   	UPD_ID = A_UPD_ID,	
  	   	    UPD_EMP_NO = A_UPD_EMP_NO,
	  	    UPD_DT = SYSDATE()
  	where COMP_ID = A_COMP_ID
  	  and NOTICE_MST_KEY = A_NOTICE_MST_KEY
  	  and NOTICE_EMP_NO = A_NOTICE_EMP_NO
  	;
			
  	IF ROW_COUNT() = 0 THEN
		SET N_RETURN = -1;
		SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
	END IF;
  	
end