CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_QUAL029$GET_MSUR_EQUICHECK_LIST`(
			IN A_ST_DATE 		TIMESTAMP,
			IN A_ED_DATE		TIMESTAMP,
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 
		  'N' as CHK, -- 선택
		  A.CHECK_ITEM, -- 점검항목
		  STR_TO_DATE(A.NEXT_DATE, '%Y%m%d') as NEXT_DATE, -- 점검예정일
		  A.EQUI_CODE, -- 관리번호
		  B.EQUI_NAME, -- 검사장비명
		  B.EQUI_SPEC, -- 규격
		  B.EQUI_NUM, -- 기기번호
		  A.CYCLE, -- 점검주기(월)
		  STR_TO_DATE(A.FINAL_DATE, '%Y%m%d') as FINAL_DATE, -- 최종점검일
		  STR_TO_DATE(A.NEXT_DATE, '%Y%m%d') as NEXT_DATE, -- 점검예정일
		  A.ETC_RMK, -- 비고
		  A.CHECK_DEPT
	from TB_MSUR_EQUICHECK A
		 left join TB_MSUR_EQUI B
		 		on A.COMP_ID = B.COMP_ID
	  			and A.EQUI_CODE = B.EQUI_CODE
	where A.NEXT_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d') and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END