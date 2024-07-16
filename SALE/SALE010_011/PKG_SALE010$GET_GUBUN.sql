CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE010$GET_GUBUN`(
	IN A_GUBUN_KIND VARCHAR(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 


	if A_GUBUN_KIND = 'CREATE' then
		select
			  'Y' as INTER_CODE
			  ,'생성' as INTER_NAME
		union all
		select
			  'N' as INTER_CODE
			  ,'미생성' as INTER_NAME 
		;
	else -- if A_GUBUN_KIND = 'END' then
		select
			  '0' as INTER_CODE
			  ,'합산마감' as INTER_NAME
		union all
		select
			  '1' as INTER_CODE
			  ,'개별마감' as INTER_NAME 
		;
	end if;


	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end