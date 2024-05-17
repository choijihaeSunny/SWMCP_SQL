CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD005$GET_MOLD_LOT_LIST_POP`(
			IN A_COMP_ID VARCHAR(10),
			IN A_ST_DATE 			TIMESTAMP,
			IN A_ED_DATE			TIMESTAMP,
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  A.LOT_NO,
		  A.MOLD_CODE,
		  C.MOLD_NAME,
		  C.MOLD_SPEC,
		  STR_TO_DATE(B.SET_DATE, '%Y%m%d') as SET_DATE,
		  B.IN_CUST,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = B.IN_CUST) as CUST_NAME,
		  B.LOT_NO_ORI,
		  B.LOT_NO_PRE,
		  B.LOT_STATE,
		  B.QTY,
		  B.WET,
		  B.HIT_CNT,
		  B.RMK 
	from TB_MOLD_STOCK A
		inner join TB_MOLD_LOT B on (A.COMP_ID = B.COMP_ID
								 and A.MOLD_CODE = B.MOLD_CODE
								 and A.LOT_NO = B.LOT_NO)
		inner join TB_MOLD C on (A.MOLD_CODE = C.MOLD_CODE)
	where A.COMP_ID = A_COMP_ID
-- 		and A.MOLD_CODE like CONCAT('%', A_MOLD_CODE, '%')
		and B.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d') and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
		and A.STOCK_QTY > 0
-- 	order by A.MOLD_CODE, STR_TO_DATE(B.SET_DATE, '%Y%m%d'), A.LOT_NO
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END