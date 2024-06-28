CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE026$DELETE_OUT_DET_LOT`(	
	IN A_COMP_ID varchar(10),
	IN A_OUT_KEY varchar(30),
	IN A_LOT_NO varchar(30),
	IN A_OUT_DATE DATETIME,
	IN A_CUST_CODE varchar(30),
	IN A_ITEM_CODE varchar(30),
	IN A_EX_RATE decimal(20,5),
	IN A_QTY decimal(20,4),
	IN A_COST decimal(20,4),
	IN A_ORDER_KEY varchar(30),
	IN A_WARE_CODE bigint(20),
	IN A_SYS_ID decimal(10,0),
	IN A_SYS_EMP_NO varchar(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE V_SUBUL_KEY varchar(100);
	declare V_STOCK_YN VARCHAR(1);
	declare V_TABLE_NAME VARCHAR(50);
	declare V_PRE_STOCK_YN VARCHAR(1);
	declare V_ITEM_KIND bigint(20);
	declare V_IO_GUBN bigint(20);
	declare V_AMT decimal(20,4);
	declare V_IO_GUBN_OUT bigint(20);
	declare V_IO_GUBN_PRE bigint(20);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
  
  	#수불 처리
	set V_SUBUL_KEY = concat('TB_OUT_DET_LOT-', A_OUT_KEY, '-', A_LOT_NO);
	set V_TABLE_NAME = 'TB_OUT_DET_LOT';
	set V_IO_GUBN_PRE = 174051; # 선점출고 
	set V_IO_GUBN_OUT = 174052; # 선점출고예정
	set V_IO_GUBN = 34305; # 출고수불

	set V_AMT = A_QTY * A_COST;

	/*if new.PRE_STOCK_KIND = 151920 then
		set V_PRE_STOCK_YN = 'N';
	else
		set V_PRE_STOCK_YN = 'Y';
	end if;*/

	select ITEM_KIND into V_ITEM_KIND from tb_item_code where ITEM_CODE = A_ITEM_CODE;


	# 수불 생성
	

	#일반수불		입출고 구분의 경우 제품만 제품으로 / 상품, 원자재, 부자재 재료로 구분 값으로 넣는다
	call SP_SUBUL_CREATE(
		A_COMP_ID, V_SUBUL_KEY, 'DELETE', date_format(A_OUT_DATE,'%Y%m%d'), '2', A_WARE_CODE, V_ITEM_KIND, A_ITEM_CODE, A_LOT_NO, 100, 
		V_IO_GUBN, A_QTY, A_COST, V_AMT, V_TABLE_NAME, A_OUT_KEY, 'Y', A_EX_RATE, '', A_CUST_CODE, 
		V_PRE_STOCK_YN, date_format(A_OUT_DATE,'%Y%m%d'), A_ORDER_KEY, V_PRE_STOCK_YN, 'Y', 'Y', 
		A_SYS_ID, A_SYS_EMP_NO, 
		N_RETURN, V_RETURN);
  	
  	if N_RETURN != 0 then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = V_RETURN;
  	end if;

  
	SET N_RETURN = 0;
  	SET V_RETURN = '삭제되었습니다.'; 
  	
  	delete FROM tb_out_det_lot
    	where COMP_ID = A_COMP_ID
    		and OUT_KEY = A_OUT_KEY
    		and LOT_NO = A_LOT_NO;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '삭제에 실패하였습니다.'; 
  	END IF;  
  
end