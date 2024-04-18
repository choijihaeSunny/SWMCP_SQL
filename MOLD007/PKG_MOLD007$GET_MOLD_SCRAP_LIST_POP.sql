CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD007$GET_MOLD_SCRAP_LIST_POP`(
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
		  COUNT(*) as CNT,
		  SUM(A.QTY) as SUM_QTY,
		  SUM(A.COST) as SUM_COST,
		  SUM(A.AMT) as SUM_AMT
#		  A.CUST_CODE,
#		  (select CUST_NAME
#		   from tc_cust_code
#		   where cust_code = A.CUST_CODE) as CUST_NAME,
#		  A.MOLD_CODE,
#		  B.MOLD_NAME,
#		  B.MOLD_SPEC,
#		  A.LOT_NO, -- input_lot?
#		  A.QTY,
#		  A.COST,
#		  A.AMT,
#		  A.DELI_DATE ? -- 납기일자? SET_DATE?
#		  A.DEPT_CODE,
#		  A.RMK
	from TB_MOLD_SCRAP A
#		left join TB_MOLD B
#		 	    on A.MOLD_CODE = B.MOLD_CODE
	where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d') and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	group by A.SET_DATE, A.SET_SEQ
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END