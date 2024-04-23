CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD006$GET_MOLD_MODI_LIST`(
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
		  A.SET_DATE,
		  A.SET_SEQ,
		  A.SET_NO,
		  A.MOLD_MODI_KEY,
		  A.MODI_DIV,
		  A.MOLD_CODE,
		  B.MOLD_NAME,
		  B.MOLD_SPEC,
		  A.LOT_NO,
		  A.QTY,
		  A.COST,
		  A.AMT,
		  A.MOLD_CODE_AFT,
		  A.LOT_NO_AFT,
		  A.DEPT_CODE,
		  A.IN_OUT,
		  A.CUST_CODE,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = A.CUST_CODE) as CUST_NAME,
		   A.CONT,
		   A.RMK
	from TB_MOLD_MODI A
		left join TB_MOLD B
		 	    on A.MOLD_CODE = B.MOLD_CODE
	where A.SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
	  and A.SET_SEQ = V_SET_SEQ
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END