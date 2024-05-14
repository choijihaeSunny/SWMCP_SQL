CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST027$DEL_WAREENDMONS`(	
	IN A_COMP_ID VARCHAR(10),
	IN A_YYMM TIMESTAMP,
	IN A_ITEM_CODE VARCHAR(30),
	IN A_ITEM_KIND BIGINT(20),
	IN A_WARE_CODE BIGINT(20),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin

	declare V_CNT INT;
	declare V_YYMM_CONF VARCHAR(6);
	declare V_YYMM VARCHAR(6);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
    set V_YYMM_CONF = DATE_FORMAT(DATE_ADD(A_YYMM, interval + 1 month), '%Y%m');
    set V_YYMM = DATE_FORMAT(A_YYMM, '%Y%m');
   
    select COUNT(*)
    into V_CNT
    from TB_IO_END
    where COMP_ID = A_COMP_ID
      and YYMM = V_YYMM_CONF
      and ITEM_CODE = A_ITEM_CODE
      and ITEM_KIND = A_ITEM_KIND
      and WARE_CODE = A_WARE_CODE
    ;
   
    if V_CNT > 0 then
		SET N_RETURN = -1;
      	SET V_RETURN = '다음달 마감이 존재합니다.'; 
	end if;
  
	delete from TB_IO_END
	where COMP_ID = A_COMP_ID
      and YYMM = V_YYMM_CONF
      and ITEM_CODE = A_ITEM_CODE
      and ITEM_KIND = A_ITEM_KIND
      and WARE_CODE = A_WARE_CODE
	;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end