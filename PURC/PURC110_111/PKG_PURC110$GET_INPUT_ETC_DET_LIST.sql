CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC110$GET_INPUT_ETC_DET_LIST`(
			IN A_INPUT_ETC_MST_KEY 		varchar(30),
            OUT N_RETURN     		 	INT,
            OUT V_RETURN      			VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
		  A.SET_NO,
		  A.INPUT_ETC_MST_KEY,
		  A.INPUT_ETC_KEY,
		  STR_TO_DATE(A.INPUT_DATE, '%Y%m%d') as INPUT_DATE,
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
		  A.DEPT_CODE,
		  A.END_AMT,
		  A.RMK
	from TB_INPUT_ETC_DET A
	where A.INPUT_ETC_MST_KEY = A_INPUT_ETC_MST_KEY
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END