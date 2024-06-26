CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD004$GET_MOLD_INPUT_LIST`(
			IN A_SET_DATE 		TIMESTAMP,
			IN A_SET_SEQ		varchar(4),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare V_SET_SEQ varchar(3);
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	if trim(A_SET_SEQ) <> '' then
		set V_SET_SEQ := LPAD(A_SET_SEQ, 3, '0');
	end if;

	select
		  A.MOLD_INPUT_KEY,
		  A.SET_SEQ,
		  A.CUST_CODE,
		  C.CUST_NAME,
		  A.MOLD_CODE,
		  B.MOLD_NAME,
		  B.MOLD_SPEC,
		  A.LOT_YN,
		  A.QTY,
		  A.IN_QTY,
		  A.COST,
		  A.AMT,
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.DEPT_CODE,
		  A.RMK,
		  A.CALL_KEY
	from TB_MOLD_INPUT A
		INNER join TB_MOLD B
		 	    on A.MOLD_CODE = B.MOLD_CODE
		LEFT join TC_CUST_CODE C
				on A.CUST_CODE = C.CUST_CODE
	where A.SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
	  and A.SET_SEQ = V_SET_SEQ
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END