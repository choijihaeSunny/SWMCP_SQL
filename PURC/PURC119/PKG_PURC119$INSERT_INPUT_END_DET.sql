CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC119$INSERT_INPUT_END_DET`(		
	IN A_COMP_ID VARCHAR(10),
	IN A_CHK VARCHAR(1),
	IN A_INPUT_END_KEY VARCHAR(30),
	IN A_ACT_DATE TIMESTAMP,
	IN A_ITEM_CODE VARCHAR(30),
	IN A_QTY DECIMAL(20, 4),
	IN A_COST DECIMAL(20, 4),
	IN A_SUPP_AMT DECIMAL(20, 4),
	IN A_VAT DECIMAL(20, 4),
	IN A_CALL_KIND VARCHAR(10),
	IN A_CALL_KEY VARCHAR(30),
	IN A_ITEM_KIND bigint(20),
	IN A_RMKS VARCHAR(100),
  	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_DET_SEQ VARCHAR(4);
	declare V_ACT_DATE VARCHAR(8);

	if A_CHK = 'Y' then
	
		set V_ACT_DATE = DATE_FORMAT(A_ACT_DATE, '%Y%m%d');

		set V_DET_SEQ = (select LPAD(IFNULL(MAX(DET_SEQ), 0) + 1, 3, 0)
						 from TB_INPUT_END_DET
						 where COMP_ID = A_COMP_ID
						   and ACT_DATE = V_ACT_DATE
						   and INPUT_END_KEY = A_INPUT_END_KEY);
	
		insert into TB_INPUT_END_DET (
			COMP_ID,
			INPUT_END_KEY,
			DET_SEQ,
			ACT_DATE,
			ITEM_CODE,
			QTY,
			COST,
			SUPP_AMT,
			VAT,
			CALL_KIND,
			CALL_KEY,
			ITEM_KIND,
			RMKS
			,SYS_ID
			,SYS_EMP_NO
			,SYS_DATE
		) values (
			A_COMP_ID,
			A_INPUT_END_KEY,
			V_DET_SEQ,
			V_ACT_DATE,
			A_ITEM_CODE,
			A_QTY,
			A_COST,
			A_SUPP_AMT,
			A_VAT,
			A_CALL_KIND,
			A_CALL_KEY,
			A_ITEM_KIND,
			A_RMKS
			,A_SYS_ID
			,A_SYS_EMP_NO
			,SYSDATE()
		)
		;
	
		if A_CALL_KIND = 'INP' then
			
			update TB_INPUT_MST
				set END_AMT = A_SUPP_AMT
			where COMP_ID = A_COMP_ID
			  and INPUT_MST_KEY = A_CALL_KEY
			;
		elseif A_CALL_KIND = 'RTN' then
			
			update TB_INPUT_RETURN_DET
				set END_AMT = A_SUPP_AMT
			where COMP_ID = A_COMP_ID
			  and INPUT_RETURN_KEY = A_CALL_KEY
			;
		elseif A_CALL_KIND = 'ETC' then
			
			update TB_INPUT_ETC_DET
				set END_AMT = A_SUPP_AMT
			where COMP_ID = A_COMP_ID
			  and INPUT_ETC_KEY = A_CALL_KEY
			;
		else -- A_CALL_KIND = 'DIS' then
			
			update TB_INPUT_DISCOUNT
				set END_AMT = A_SUPP_AMT
			where COMP_ID = A_COMP_ID
			  and DS_KEY = A_CALL_KEY
			;
		end if;
	
		SET N_RETURN = 0;
  		SET V_RETURN = '저장되었습니다.';
	end if;
  	
end