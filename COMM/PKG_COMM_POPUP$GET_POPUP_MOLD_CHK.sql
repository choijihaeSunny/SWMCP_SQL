CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_COMM_POPUP$GET_POPUP_MOLD_CHK`(
			IN A_MOLD_CODE		VARCHAR(20),
			IN A_MOLD_NAME		VARCHAR(50),
			IN A_USE_YN			VARCHAR(5),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  A.MOLD_CODE,
		  A.MOLD_NAME,
		  A.MOLD_SPEC,
		  A.LOT_YN,
		  A.STOCK_SAFE,
		  A.CUST_CODE,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = A.CUST_CODE) as CUST_NAME,
		  A.ITEM_UNIT,
		  A.RMK,
		  A.CODE_PRE,
		  A.WARE_POS,
		  A.USE_YN
	from TB_MOLD A
	where A.MOLD_CODE LIKE CONCAT('%', A_MOLD_CODE, '%')
	  and A.MOLD_NAME like CONCAT('%', A_MOLD_NAME, '%')
	  and A.USE_YN = A_USE_YN
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END