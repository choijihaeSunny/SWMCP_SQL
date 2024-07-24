CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE012$GET_SALES_COLL_LIST`(
			IN A_COMP_ID		varchar(10),
			IN A_SET_DATE 		TIMESTAMP,
			IN A_CUST_CODE		VARCHAR(10),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare V_DATE VARCHAR(8);
	declare V_YYMM VARCHAR(6);

	-- 1달 전
	declare V_PRE VARCHAR(6);
	declare V_PRE_YYMM VARCHAR(8);
	declare V_PRE_LAST_DAY VARCHAR(8);
	
	-- 2달 전
	declare V_PPRE VARCHAR(6);
	declare V_PPRE_YYMM VARCHAR(8);
	declare V_PPRE_LAST_DAY VARCHAR(8);

	-- ~3달 전
	declare V_3PRE VARCHAR(6);
	declare V_3PRE_YYMM VARCHAR(8);
	declare V_3PRE_LAST_DAY VARCHAR(8);

	-- 올해의 시작일
	declare V_FROM_DATE VARCHAR(8);	
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	set V_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d');
	set V_YYMM = SUBSTR(V_DATE, 1, 6);

	set V_PRE = SUBSTR(DATE_FORMAT(DATE_ADD(A_SET_DATE, interval -1 MONTH), '%Y%m%d'), 1, 6);
	set V_PPRE = SUBSTR(DATE_FORMAT(DATE_ADD(A_SET_DATE, interval -2 MONTH), '%Y%m%d'), 1, 6);
	set V_3PRE = SUBSTR(DATE_FORMAT(DATE_ADD(A_SET_DATE, interval -3 MONTH), '%Y%m%d'), 1, 6);

	set V_PRE_YYMM = CONCAT(V_PRE_YYMM, '01');
	set V_PPRE_YYMM = CONCAT(V_PPRE_YYMM, '01');
	set V_3PRE_YYMM = CONCAT(V_3PRE_YYMM, '01');

	set V_PRE_LAST_DAY = CONCAT(V_PRE_YYMM, '31');
	set V_PPRE_LAST_DAY = CONCAT(V_PPRE_YYMM, '31');
	set V_3PRE_LAST_DAY = CONCAT(V_3PRE_YYMM, '31');

	set V_FROM_DATE = CONCAT(SUBSTR(V_DATE, 1, 4), '0101');

	select
		  A.KIND
		  ,A.COMP_ID
		  ,A.SET_DATE
		  ,A.CUST_CODE
		  ,A.SALES_KIND
		  ,A.ITEM_CODE
		  ,A.QTY
		  ,A.SALE_AMT
		  ,A.COLL_AMT
	from vew_sales_coll_det A
	
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END