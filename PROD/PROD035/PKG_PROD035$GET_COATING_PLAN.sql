CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROD035$GET_COATING_PLAN`(	
	in A_COMP_ID VARCHAR(10),
	in A_DEPT_CODE	VARCHAR(10),
	in A_ST_DATE DATETIME,
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_DATE	VARCHAR(8);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET V_SET_DATE = date_format(A_ST_DATE,'%Y%m%d');

	select
		  A.COMP_ID,
		  A.MATR_LOT_NO,
		  A.SET_SEQ,
		  A.PLAN_MST_KEY,
		  A.WORK_LINE,
#		  A.ORDER_KEY,
		  A.MATR_CODE,
		  A.PROG_CODE,
		  A.PLAN_TOT_QTY,
		  A.STOCK_QTY,
		  A.DEPT_CODE,
		  A.WARE_CODE,
#		  D.QTY as ORDER_QTY,
		  C.ITEM_NAME,
		  C.ITEM_SPEC,
		  
		  NVL(B.PLAN_QTY01,0) as PLAN_QTY01, NVL(B.PLAN_QTY02,0) as PLAN_QTY02, NVL(B.PLAN_QTY03,0) as PLAN_QTY03, NVL(B.PLAN_QTY04,0) as PLAN_QTY04, 
	 	  NVL(B.PLAN_QTY05,0) as PLAN_QTY05, NVL(B.PLAN_QTY06,0) as PLAN_QTY06, NVL(B.PLAN_QTY07,0) as PLAN_QTY07, NVL(B.PLAN_QTY08,0) as PLAN_QTY08, 
	      NVL(B.PLAN_QTY09,0) as PLAN_QTY09, NVL(B.PLAN_QTY10,0) as PLAN_QTY10, NVL(B.PLAN_QTY11,0) as PLAN_QTY11, NVL(B.PLAN_QTY12,0) as PLAN_QTY12, 
		  NVL(B.PLAN_QTY13,0) as PLAN_QTY13, NVL(B.PLAN_QTY14,0) as PLAN_QTY14, NVL(B.PLAN_QTY15,0) as PLAN_QTY15, NVL(B.PLAN_QTY16,0) as PLAN_QTY16, 
		  NVL(B.PLAN_QTY17,0) as PLAN_QTY17, NVL(B.PLAN_QTY18,0) as PLAN_QTY18, NVL(B.PLAN_QTY19,0) as PLAN_QTY19, NVL(B.PLAN_QTY20,0) as PLAN_QTY20,

		  B.CONFIRM_YN01, B.CONFIRM_YN02, B.CONFIRM_YN03, B.CONFIRM_YN04, B.CONFIRM_YN05, B.CONFIRM_YN06, B.CONFIRM_YN07,
		  B.CONFIRM_YN08, B.CONFIRM_YN09, B.CONFIRM_YN10, B.CONFIRM_YN11, B.CONFIRM_YN12, B.CONFIRM_YN13, B.CONFIRM_YN14,
		  B.CONFIRM_YN15, B.CONFIRM_YN16, B.CONFIRM_YN17, B.CONFIRM_YN18, B.CONFIRM_YN19, B.CONFIRM_YN20,
		
		  B.END_YN01, B.END_YN02, B.END_YN03, B.END_YN04, B.END_YN05, B.END_YN06, B.END_YN07,
		  B.END_YN08, B.END_YN09, B.END_YN10, B.END_YN11, B.END_YN12, B.END_YN13, B.END_YN14,
		  B.END_YN15, B.END_YN16, B.END_YN17, B.END_YN18, B.END_YN19, B.END_YN20,
		  
		  A.RMK
	from TB_COATING_PLAN A
		left outer join (
			select 
				  AA.COMP_ID, BB.PLAN_MST_KEY,
				  SUM(case when AA.CAL_ROWNUM = 1 then BB.PLAN_QTY else 0 end) as PLAN_QTY01,
				  SUM(case when AA.CAL_ROWNUM = 2 then BB.PLAN_QTY else 0 end) as PLAN_QTY02,
				  SUM(case when AA.CAL_ROWNUM = 3 then BB.PLAN_QTY else 0 end) as PLAN_QTY03,
				  SUM(case when AA.CAL_ROWNUM = 4 then BB.PLAN_QTY else 0 end) as PLAN_QTY04,
				  SUM(case when AA.CAL_ROWNUM = 5 then BB.PLAN_QTY else 0 end) as PLAN_QTY05,
				  SUM(case when AA.CAL_ROWNUM = 6 then BB.PLAN_QTY else 0 end) as PLAN_QTY06,
				  SUM(case when AA.CAL_ROWNUM = 7 then BB.PLAN_QTY else 0 end) as PLAN_QTY07,
				  SUM(case when AA.CAL_ROWNUM = 8 then BB.PLAN_QTY else 0 end) as PLAN_QTY08,
				  SUM(case when AA.CAL_ROWNUM = 9 then BB.PLAN_QTY else 0 end) as PLAN_QTY09,
				  SUM(case when AA.CAL_ROWNUM = 10 then BB.PLAN_QTY else 0 end) as PLAN_QTY10,
				  SUM(case when AA.CAL_ROWNUM = 11 then BB.PLAN_QTY else 0 end) as PLAN_QTY11,
				  SUM(case when AA.CAL_ROWNUM = 12 then BB.PLAN_QTY else 0 end) as PLAN_QTY12,
				  SUM(case when AA.CAL_ROWNUM = 13 then BB.PLAN_QTY else 0 end) as PLAN_QTY13,
				  SUM(case when AA.CAL_ROWNUM = 14 then BB.PLAN_QTY else 0 end) as PLAN_QTY14,
				  SUM(case when AA.CAL_ROWNUM = 15 then BB.PLAN_QTY else 0 end) as PLAN_QTY15,
				  SUM(case when AA.CAL_ROWNUM = 16 then BB.PLAN_QTY else 0 end) as PLAN_QTY16,
				  SUM(case when AA.CAL_ROWNUM = 17 then BB.PLAN_QTY else 0 end) as PLAN_QTY17,
				  SUM(case when AA.CAL_ROWNUM = 18 then BB.PLAN_QTY else 0 end) as PLAN_QTY18,
				  SUM(case when AA.CAL_ROWNUM = 19 then BB.PLAN_QTY else 0 end) as PLAN_QTY19,
				  SUM(case when AA.CAL_ROWNUM = 20 then BB.PLAN_QTY else 0 end) as PLAN_QTY20,
				  
				  MAX(case when AA.CAL_ROWNUM = 1 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN01,
				  MAX(case when AA.CAL_ROWNUM = 2 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN02,
				  MAX(case when AA.CAL_ROWNUM = 3 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN03,
				  MAX(case when AA.CAL_ROWNUM = 4 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN04,
				  MAX(case when AA.CAL_ROWNUM = 5 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN05,
				  MAX(case when AA.CAL_ROWNUM = 6 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN06,
				  MAX(case when AA.CAL_ROWNUM = 7 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN07,
				  MAX(case when AA.CAL_ROWNUM = 8 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN08,
				  MAX(case when AA.CAL_ROWNUM = 9 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN09,
				  MAX(case when AA.CAL_ROWNUM = 10 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN10,
				  MAX(case when AA.CAL_ROWNUM = 11 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN11,
				  MAX(case when AA.CAL_ROWNUM = 12 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN12,
				  MAX(case when AA.CAL_ROWNUM = 13 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN13,
				  MAX(case when AA.CAL_ROWNUM = 14 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN14,
				  MAX(case when AA.CAL_ROWNUM = 15 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN15,
				  MAX(case when AA.CAL_ROWNUM = 16 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN16,
				  MAX(case when AA.CAL_ROWNUM = 17 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN17,
				  MAX(case when AA.CAL_ROWNUM = 18 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN18,
				  MAX(case when AA.CAL_ROWNUM = 19 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN19,
				  MAX(case when AA.CAL_ROWNUM = 20 then BB.CONFIRM_YN else 'N' end) as CONFIRM_YN20,
				  
				  MAX(case when AA.CAL_ROWNUM = 1 then BB.END_YN else 'N' end) as END_YN01,
				  MAX(case when AA.CAL_ROWNUM = 2 then BB.END_YN else 'N' end) as END_YN02,
				  MAX(case when AA.CAL_ROWNUM = 3 then BB.END_YN else 'N' end) as END_YN03,
				  MAX(case when AA.CAL_ROWNUM = 4 then BB.END_YN else 'N' end) as END_YN04,
				  MAX(case when AA.CAL_ROWNUM = 5 then BB.END_YN else 'N' end) as END_YN05,
				  MAX(case when AA.CAL_ROWNUM = 6 then BB.END_YN else 'N' end) as END_YN06,
				  MAX(case when AA.CAL_ROWNUM = 7 then BB.END_YN else 'N' end) as END_YN07,
				  MAX(case when AA.CAL_ROWNUM = 8 then BB.END_YN else 'N' end) as END_YN08,
				  MAX(case when AA.CAL_ROWNUM = 9 then BB.END_YN else 'N' end) as END_YN09,
				  MAX(case when AA.CAL_ROWNUM = 10 then BB.END_YN else 'N' end) as END_YN10,
				  MAX(case when AA.CAL_ROWNUM = 11 then BB.END_YN else 'N' end) as END_YN11,
				  MAX(case when AA.CAL_ROWNUM = 12 then BB.END_YN else 'N' end) as END_YN12,
				  MAX(case when AA.CAL_ROWNUM = 13 then BB.END_YN else 'N' end) as END_YN13,
				  MAX(case when AA.CAL_ROWNUM = 14 then BB.END_YN else 'N' end) as END_YN14,
				  MAX(case when AA.CAL_ROWNUM = 15 then BB.END_YN else 'N' end) as END_YN15,
				  MAX(case when AA.CAL_ROWNUM = 16 then BB.END_YN else 'N' end) as END_YN16,
				  MAX(case when AA.CAL_ROWNUM = 17 then BB.END_YN else 'N' end) as END_YN17,
				  MAX(case when AA.CAL_ROWNUM = 18 then BB.END_YN else 'N' end) as END_YN18,
				  MAX(case when AA.CAL_ROWNUM = 19 then BB.END_YN else 'N' end) as END_YN19,
				  MAX(case when AA.CAL_ROWNUM = 20 then BB.END_YN else 'N' end) as END_YN20
			from   (
					select 
						  COMP_ID, 
						  CONCAT(YYYY, MM, DD) as CAL_DATE, 
						  ROW_NUMBER() OVER(order by CONCAT(YYYY, MM, DD) asc) as CAL_ROWNUM
					from TC_FACT_CAL
					where COMP_ID = A_COMP_ID 
					  and DEPT_CODE = A_DEPT_CODE
					  and HOLY_KND = 'D'
					  and CONCAT(YYYY, MM, DD) >= V_SET_DATE
					) AA
					left outer join TB_COATING_PLAN_DET BB
						on AA.COMP_ID = BB.COMP_ID 
						and AA.CAL_DATE = BB.PLAN_DATE 
			where  AA.CAL_ROWNUM <= 20	/* 부서별 회사달력 기준으로 20일 내역 조회되도록 처리   */
			group by AA.COMP_ID, BB.PLAN_MST_KEY
		) B
			on A.COMP_ID = B.COMP_ID 
			and A.PLAN_MST_KEY = B.PLAN_MST_KEY
		inner join TB_ITEM_CODE C on A.MATR_CODE = C.ITEM_CODE
-- 		inner join TB_ORDER_DET D on A.COMP_ID = D.COMP_ID 
-- 		 						 and A.ORDER_KEY = D.ORDER_KEY
	where A.COMP_ID = A_COMP_ID
	  and A.DEPT_CODE = A_DEPT_CODE
	group by A.MATR_CODE, A.MATR_LOT_NO
	;
		
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
   
END