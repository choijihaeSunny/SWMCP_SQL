CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_QUAL029$GET_MSUR_EQUICHECK_LIST2`(
			IN A_EQUI_CODE 		varchar(3),
			IN A_DATE 			TIMESTAMP,
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  A.IDX,
		  A.EQUI_CODE, -- 관리번호
		  A.CHECK_ITEM, -- 점검항목
		  B.EQUI_NAME, -- 검사장비명 
		  B.EQUI_SPEC, -- 규격
		  B.EQUI_NUM, -- 기기번호
		  A.CYCLE, -- 점검주기(월)
		  STR_TO_DATE(A.FINAL_DATE, '%Y%m%d') as FINAL_DATE, -- 최종점검일
		  A.CHECK_DEPT, -- 점검기관
		  A.CHECK_RESULT, -- 점검결과
		  A.CHECK_EMP_NO, -- 점검자
		  A.VALID_TEMP, -- 유효기간
		  'UPLOADFILE' AS UPLOADFILE, -- 성적서 업로드
		  'VIEWFILE' AS VIEWFILE, -- 성적서 업로드
		  IFNULL(A.FILE_NAME, '') as FILE_NAME,
		  IFNULL(A.REAL_FILE_NAME, '') as REAL_FILE_NAME,
		  '' as FILE_NAME_DEL,
		  '' as REAL_FILE_NAME_DEL,
		  '' as FILE_NAME_OLD,
		  A.CHECK_HIS, -- 점검내용
		  A.RESULT_HIS, -- 조치내용
		  A.ETC_RMK -- 비고
		  ,A.TEMP_SEQ
		  ,A.SET_DATE
	from tb_msur_equicheck_result A
		 left join tb_msur_equi B
		 		on A.COMP_ID = B.COMP_ID
	  			and A.EQUI_CODE = B.EQUI_CODE
	where A.SET_DATE = DATE_FORMAT(A_DATE, '%Y%m%d')
	  and A.TEMP_SEQ = LPAD(A_EQUI_CODE, 3, '0')
	;

	  		
	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END