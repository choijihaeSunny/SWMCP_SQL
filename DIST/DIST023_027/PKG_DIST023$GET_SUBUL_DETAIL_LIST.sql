CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST023$GET_SUBUL_DETAIL_LIST`(	
	in A_COMP_ID VARCHAR(10),
	IN A_ST_DATE TIMESTAMP,
	IN A_ED_DATE TIMESTAMP,
	in A_ITEM_CODE VARCHAR(30),
	in A_ITEM_NAME VARCHAR(100),
	in A_ITEM_KIND BIGINT(20),  -- 무조건 선택하여 조회해야 한다.
	in A_WARE_CODE bigint(20),  -- 무조건 선택하여 조회해야 한다.
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_ST_DATE VARCHAR(8);
	declare V_ED_DATE VARCHAR(8);
	
	declare V_PRE_DATE VARCHAR(8);
	declare V_END_YYMM VARCHAR(8);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	set V_ST_DATE = DATE_FORMAT(A_ST_DATE, '%Y%m%d');
	set V_ED_DATE = DATE_FORMAT(A_ED_DATE, '%Y%m%d');
	set V_PRE_DATE = DATE_FORMAT(DATE_ADD(A_ST_DATE, interval - 1 day), '%Y%m%d'); -- 이월된 값(하루 전)
	-- TO_CHAR(V_SETDATE - 1, 'YYYYMMDD') 이 하루 전으로 표시된다...

	-- LEETEK의 PKG_ITEMSTOCKDETAILR, PKG_MATRSTOCKDETAILR 참조
	-- TC_IO_END <=> TB_IO_END
	-- VIEW_ITEM_CODE <=> TB_ITEM_CODE ? VIEW_ITEM ? 
	-- TC_SUBUL_ITEM, TC_SUBUL_MATR <=> TB_SUBUL ?
	
	select
		  MAX(YYMM)
	into V_END_YYMM
	from TB_IO_END A
		inner join VIEW_ITEM B
		on A.ITEM_CODE = B.ITEM_CODE
	where A.COMP_ID = A_COMP_ID
	  and A.YYMM < SUBSTRING(V_ST_DATE, 1, 6)
	  and A.WARE_CODE = A_WARE_CODE
	;

	if V_END_YYMM is null then
		set V_END_YYMM = '202001';
	end if;
	
	--
	select
		  A.TOP_SORT, A.IN_OUT, A.ITEM_CODE, A.ITEM_CODE as ITEM_CODE_2, /*STR_TO_DATE(A.IO_DATE, '%Y%m%d') as IO_DATE*/A.IO_DATE, A.ITEM_NAME,
		  A.ITEM_SPEC, A.IO_GUBUN, A.PRE_QTY, A.IN_QTY, A.OUT_QTY,
		  SUM(A.NEXT_QTY) OVER(PARTITION BY A.ITEM_CODE 
		  					   ORDER BY A.TOP_SORT, A.IO_DATE, A.IN_OUT, A.KEY_VAL) AS STOCK_QTY,
		  A.PRE_AMT, A.IN_AMT, A.OUT_AMT, 
		  SUM(A.NEXT_AMT) OVER(PARTITION BY A.ITEM_CODE 
		  					   ORDER BY A.TOP_SORT, A.IO_DATE, A.IN_OUT, A.KEY_VAL) AS STOCK_AMT,
		  A.LOT_NO
	from (
		select
			  '0' as TOP_SORT, '0' as IN_OUT, AA.ITEM_CODE, AA.ITEM_NAME, AA.ITEM_SPEC,
			  '이월' as IO_DATE, '' as IO_GUBUN,
			  SUM(case when AA.IN_OUT = '1' then AA.IO_QTY else AA.IO_QTY * -1 END) as PRE_QTY,
			  0 as IN_QTY, 0 as OUT_QTY,
			  SUM(case when AA.IN_OUT = '1' then AA.IO_QTY else AA.IO_QTY * -1 END) as NEXT_QTY,
			  '' as KEY_VAL,
			  SUM(case when AA.IN_OUT = '1' then AA.IO_AMT else AA.IO_AMT * -1 END) as PRE_AMT,
			  0 as IN_AMT, 0 as OUT_AMT,
			  SUM(case when AA.IN_OUT = '1' then AA.IO_AMT else AA.IO_AMT * -1 END) as NEXT_AMT,
			  AA.LOT_NO
		from (
			select	-- 마감한 내역
				  AAA.ITEM_CODE, BBB.ITEM_NAME, BBB.ITEM_SPEC, '1' as IN_OUT, AAA.NEXT_QTY as IO_QTY,
				  AAA.NEXT_AMT as IO_AMT, AAA.LOT_NO
			from TB_IO_END AAA
				inner join VIEW_ITEM BBB
					on AAA.ITEM_CODE = BBB.ITEM_CODE
			where AAA.COMP_ID = A_COMP_ID
			  and AAA.WARE_CODE = A_WARE_CODE
			  and AAA.YYMM = V_END_YYMM
			  and AAA.ITEM_CODE like CONCAT('%', A_ITEM_CODE, '%')
			  and AAA.ITEM_KIND = A_ITEM_KIND 
			union all 
			select	-- 이월한(주어진 기간 이전의 내역 중 마감되지 않은) 내역
				  AAA.ITEM_CODE, BBB.ITEM_NAME, BBB.ITEM_SPEC, AAA.IN_OUT, AAA.IO_QTY,
				  AAA.IO_AMT, AAA.LOT_NO
			from TB_SUBUL AAA
				inner join VIEW_ITEM BBB
					on AAA.ITEM_CODE = BBB.ITEM_CODE
			where AAA.COMP_ID = A_COMP_ID
			  and AAA.WARE_CODE = A_WARE_CODE
			  and AAA.IO_DATE between CONCAT(V_END_YYMM, '32') and V_PRE_DATE
			  and AAA.ITEM_CODE like CONCAT('%', A_ITEM_CODE, '%')
			  and AAA.ITEM_KIND = A_ITEM_KIND
		) AA
		group by AA.ITEM_CODE, AA.ITEM_NAME, AA.ITEM_SPEC
		union all
		select -- 기간 내의 내역
			  '1' as TOP_SORT, AA.IN_OUT, AA.ITEM_CODE, BB.ITEM_NAME, BB.ITEM_SPEC,
			  AA.IO_DATE, AA.IO_GUBN, 
			  0 as PRE_QTY,
			  (case when IN_OUT = '1' then IO_QTY else 0 END) as IN_QTY,
			  (case when IN_OUT = '2' then IO_QTY else 0 END) as OUT_QTY,
			  (case when IN_OUT = '1' then IO_QTY else IO_QTY * -1 END) as NEXT_QTY,
			  AA.KEY_VAL, 0 as PRE_AMT,
			  (case when IN_OUT = '1' then IO_AMT else 0 END) as IN_AMT,
			  (case when IN_OUT = '2' then IO_AMT else 0 END) as OUT_AMT,
			  (case when IN_OUT = '1' then IO_AMT else IO_AMT * -1 END) as NEXT_AMT,
			  AA.LOT_NO
		from TB_SUBUL AA
			inner join VIEW_ITEM BB
				on AA.ITEM_CODE = BB.ITEM_CODE
		where AA.COMP_ID = A_COMP_ID
		  and AA.WARE_CODE = A_WARE_CODE
		  and AA.IO_DATE between V_ST_DATE and V_ED_DATE
		  and AA.ITEM_CODE like CONCAT('%', A_ITEM_CODE, '%')
		  and AA.ITEM_KIND = A_ITEM_KIND
	) A
	order by A.IO_DATE, A.PRE_QTY, A.IN_QTY, A.OUT_QTY
	;

	--

	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end