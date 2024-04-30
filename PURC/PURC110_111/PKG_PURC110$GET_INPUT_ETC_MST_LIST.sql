CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC110$GET_INPUT_ETC_MST_LIST`(
			IN A_SET_DATE 		TIMESTAMP,
			IN A_SET_SEQ		varchar(4),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare V_SET_SEQ varchar(4);
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	if trim(A_SET_SEQ) <> '' then
		set V_SET_SEQ := LPAD(A_SET_SEQ, 4, '0');
	end if;

	select
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
		  A.INPUT_ETC_MST_KEY,
		  STR_TO_DATE(A.INPUT_DATE, '%Y%m%d') as INPUT_DATE,
		  A.CUST_CODE,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = A.CUST_CODE) as CUST_NAME,
		  A.EMP_NO,
		  A.DEPT_CODE,
		  A.SHIP_INFO,
		  A.PJ_NO,
		  A.PJ_NAME,
		  A.RMKS
	from TB_INPUT_ETC_MST A
	where A.INPUT_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
	  and A.SET_SEQ = V_SET_SEQ
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END