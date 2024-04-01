CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_QUAL027$GET_MSUR_EQUI_LIST`(
			IN A_CLASS1 		bigint(20),
			IN A_EQUI_NAME		VARCHAR(50),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	DECLARE V_RACK_DIV VARCHAR(20);
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  A.EQUI_CODE, -- 관리번호
		  A.EQUI_NAME, -- 검사장비명
		  A.EQUI_SPEC, -- 규격
		  A.EQUI_NUM, -- 기기번호
		  A.MAKE_COMP, -- 제조사
		  A.MODEL_NAME, -- 모델명
		  A.BUY_AMT, -- 구입가격
		  A.BUY_COMP, -- 구매처
		  A.BUY_DATE, -- 구입일자
		  B.CHECK_ITEM, -- 점검항목
		  B.CYCLE, -- 점검주기(월)
		  B.FINAL_DATE, -- 최종점검일
		  B.NEXT_DATE, -- 차기점검일
		  A.USE_DEPT, -- 사용부서
		  A.RES_STATUS, -- 지원상태
		  A.ETC_RMK -- 비고
	from TB_MSUR_EQUI A
		 left join TB_MSUR_EQUICHECK B
		 	    on A.COMP_ID = B.COMP_ID
	  			and A.EQUI_CODE = B.EQUI_CODE
	where A.CLASS1 LIKE CONCAT('%', A_CLASS1, '%')
	  and A.EQUI_NAME like CONCAT('%', A_EQUI_NAME, '%')
	;
	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END