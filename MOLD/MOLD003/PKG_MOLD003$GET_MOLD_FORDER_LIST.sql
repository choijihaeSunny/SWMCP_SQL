CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD003$GET_MOLD_FORDER_LIST`(
			IN A_COMP_ID		VARCHAR(10),
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
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
		  A.SET_NO,
		  A.MOLD_MORDER_KEY,
		  A.MOLD_CODE,
		  B.MOLD_NAME,
		  B.MOLD_SPEC,
		  A.CUST_CODE,
		  C.CUST_NAME,
		  A.QTY,
		  STR_TO_DATE(A.DELI_DATE, '%Y%m%d') as DELI_DATE,
		  A.COST,
		  A.AMT,
		  A.EMP_NO,
		  E.KOR_NAME as EMP_NAME,
		  A.DEPT_CODE,
		  A.RMK,
		  A.CALL_KEY
	from TB_MOLD_FORDER A
		INNER join TB_MOLD B
		 	    on A.MOLD_CODE = B.MOLD_CODE
		LEFT join TC_CUST_CODE C
				on A.CUST_CODE = C.CUST_CODE
		LEFT join INSA_MST E
				on A.EMP_NO = E.EMP_NO
	where A.COMP_ID = A_COMP_ID 
	  and A.SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
	  and A.SET_SEQ = V_SET_SEQ
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END