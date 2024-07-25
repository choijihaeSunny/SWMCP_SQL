CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE012$GET_SALES_COLL_LIST`(
			IN A_COMP_ID		varchar(10),
			IN A_SET_DATE 		TIMESTAMP,
			IN A_CUST_CODE		VARCHAR(10),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	-- 기준일
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

	-- 올해의 시작일 (20xx.01.01)
	declare V_FROM_DATE VARCHAR(8);	
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	set V_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d');
	set V_YYMM = SUBSTR(V_DATE, 1, 6);

	set V_PRE = SUBSTR(DATE_FORMAT(DATE_ADD(A_SET_DATE, interval -1 MONTH), '%Y%m%d'), 1, 6);
	set V_PPRE = SUBSTR(DATE_FORMAT(DATE_ADD(A_SET_DATE, interval -2 MONTH), '%Y%m%d'), 1, 6);
	set V_3PRE = SUBSTR(DATE_FORMAT(DATE_ADD(A_SET_DATE, interval -3 MONTH), '%Y%m%d'), 1, 6);

	set V_PRE_YYMM = CONCAT(V_PRE, '01');
	set V_PPRE_YYMM = CONCAT(V_PPRE, '01');
	set V_3PRE_YYMM = CONCAT(V_3PRE, '01');

	set V_PRE_LAST_DAY = CONCAT(V_PRE, '31');
	set V_PPRE_LAST_DAY = CONCAT(V_PPRE, '31');
	set V_3PRE_LAST_DAY = CONCAT(V_3PRE, '31');

	set V_FROM_DATE = CONCAT(SUBSTR(V_DATE, 1, 4), '0101');

	-- 신진화스너의 d_coll_bill_misu_inq1_new 참조.
	-- COLL_DC_AMT (수금할인) 은 여기서는 사용하지 않아 생략되었다.

	select
		  A.CUST_CODE,
		  C.CUST_NAME,
		  SUM(A.MISU_CURR) as CURR,
		  (SUM(A.MISU_CURR) - case when SUM(A.MISU_PRE) < 0 then 0 else SUM(A.MISU_PRE) end) as MISU_MON,
		  (case when SUM(A.MISU_PRE) < 0 then 0 else SUM(A.MISU_PRE) end) - (case when SUM(A.MISU_PPRE) < 0 then 0 else SUM(A.MISU_PPRE) end) as PRE,
		  (case when SUM(A.MISU_PPRE) < 0 then 0 else SUM(A.MISU_PPRE) end) - (case when SUM(A.MISU_3PRE) < 0 then 0 else SUM(A.MISU_3PRE) end) as PPRE,
		  (case when SUM(A.MISU_3PRE) < 0 then 0 else SUM(A.MISU_3PRE) end) as PRE3
	from (
		select
			  CUST_CODE,
			  SUM(SALE_AMT - COLL_AMT) as MISU_CURR,
			  SUM(SALE_AMT - COLL_AMT) as MISU_PRE,
			  SUM(SALE_AMT - COLL_AMT) as MISU_PPRE,
			  SUM(SALE_AMT - COLL_AMT) as MISU_3PRE
		from VEW_SALES_COLL_DET
		where COMP_ID = A_COMP_ID
		  and SET_DATE between V_FROM_DATE and V_3PRE_LAST_DAY
		  and not(SET_DATE <> V_FROM_DATE) -- 올해 시작일 ~ 3개월 전 까지의 내역.
		group by CUST_CODE
		union all 
		select
			  CUST_CODE,
			  0 as MISU_CURR,
			  0 as MISU_PRE,
			  0 as MISU_PPRE,
			  SUM(COLL_AMT * -1) as MISU_3PRE
		from VEW_SALES_COLL_DET
		where COMP_ID = A_COMP_ID
		  and SET_DATE <= V_PPRE_LAST_DAY
		  and SET_DATE > V_3PRE_LAST_DAY -- 3개월 전 ~ 2개월전까지의 미수금 내역
		group by CUST_CODE
		union all 
		select 
			  CUST_CODE,
			  SUM(SALE_AMT - COLL_AMT) as MISU_CURR,
			  SUM(SALE_AMT - COLL_AMT) as MISU_PRE,
			  SUM(SALE_AMT - COLL_AMT) as MISU_PPRE,
			  0 as MISU_3PRE
		from VEW_SALES_COLL_DET
		where COMP_ID = A_COMP_ID
		  and SET_DATE <= V_PPRE_LAST_DAY and SET_DATE > V_3PRE_LAST_DAY
		group by CUST_CODE
		union all 
		select
			  CUST_CODE,
			  0 as MISU_CURR,
			  0 as MISU_PRE,
			  SUM(COLL_AMT * -1) as MISU_PPRE,
			  SUM(COLL_AMT * -1) as MISU_3PRE
		from VEW_SALES_COLL_DET
		where COMP_ID = A_COMP_ID
		  and SET_DATE <= V_PRE_LAST_DAY and SET_DATE > V_PPRE_LAST_DAY
		group by CUST_CODE
		union all
		select 
			  CUST_CODE,
			  SUM(SALE_AMT - COLL_AMT) as MISU_CURR,
			  SUM(SALE_AMT - COLL_AMT) as MISU_PRE,
			  0 as MISU_PPRE,
			  0 as MISU_3PRE
		from VEW_SALES_COLL_DET
		where COMP_ID = A_COMP_ID
		  and SET_DATE <= V_PRE_LAST_DAY and SET_DATE > V_PPRE_LAST_DAY
		group by CUST_CODE
		union all 
		select
			  CUST_CODE,
			  0 as MISU_CURR,
			  SUM(COLL_AMT * -1) as MISU_PRE,
			  SUM(COLL_AMT * -1) as MISU_PPRE,
			  SUM(COLL_AMT * -1) as MISU_3PRE
		from VEW_SALES_COLL_DET
		where COMP_ID = A_COMP_ID
		  and SET_DATE <= V_DATE and SET_DATE > V_PRE_LAST_DAY
		group by CUST_CODE
		union all 
		select 
			  CUST_CODE,
			  SUM(SALE_AMT - COLL_AMT) as MISU_CURR,
			  0 as MISU_PRE,
			  0 as MISU_PPRE,
			  0 as MISU_3PRE
		from VEW_SALES_COLL_DET
		where COMP_ID = A_COMP_ID
		  and SET_DATE <= V_DATE and SET_DATE > V_PRE_LAST_DAY
		group by CUST_CODE
	) A
		/*
		inner join TC_CUST_EMP B -- 테이블 형식이 실제 사용되는 테이블인지 잘 모르겠어서 생략 하였다.
			on (B.COMP_ID = A_COMP_ID
			and A.CUST_CODE = B.CUST_CODE)
		*/
		inner join TC_CUST_CODE C 
			on (C.COMP_ID = A_COMP_ID
			and A.CUST_CODE = C.CUST_CODE)
	where A.CUST_CODE like CONCAT('%', A_CUST_CODE, '%')
	group by A.CUST_CODE,
			 C.CUST_NAME
	having SUM(A.MISU_CURR) <> 0 
	    or (SUM(A.MISU_CURR) - (case when SUM(A.MISU_PRE) < 0 then 0 else SUM(A.MISU_PRE) end)) <> 0
	    or ((case when SUM(A.MISU_PRE) < 0 then 0 else SUM(A.MISU_PRE) end) - (case when SUM(A.MISU_PPRE) < 0 then 0 else SUM(A.MISU_PPRE) end)) <> 0
	    or ((case when SUM(A.MISU_PPRE) < 0 then 0 else SUM(A.MISU_PPRE) end) - (case when SUM(A.MISU_3PRE) < 0 then 0 else SUM(A.MISU_3PRE) end)) <> 0
	    or (case when SUM(A.MISU_3PRE) < 0 then 0 else SUM(A.MISU_3PRE) end) <> 0
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END