CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC114$GET_TB_STOCK_MOVE_LIST_POP`(
			IN A_ST_DATE 			TIMESTAMP,
			IN A_ED_DATE			TIMESTAMP,
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
		  A.SET_NO,
		  A.MOVE_KEY,
		  STR_TO_DATE(A.MOVE_DATE, '%Y%m%d') as MOVE_DATE,
		  A.ITEM_CODE,
		  (select ITEM_NAME
		   from TB_ITEM_CODE
		   where ITEM_CODE = A.ITEM_CODE) as ITEM_NAME,
		  (select ITEM_SPEC
		   from TB_ITEM_CODE
		   where ITEM_CODE = A.ITEM_CODE) as ITEM_SPEC,
		  A.LOT_NO,
		  A.QTY,
		  A.COST,
		  A.AMT,
		  A.WARE_CODE,
		  A.WARE_CODE_PRE,
		  A.ITEM_KIND,
		  A.RMK
	from TB_STOCK_MOVE A
	where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d') and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END