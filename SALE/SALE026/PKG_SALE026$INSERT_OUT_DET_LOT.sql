CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE026$INSERT_OUT_DET_LOT`(	
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE DATETIME,
	IN A_SET_SEQ varchar(4),
	IN A_SET_NO varchar(4),
	IN A_OUT_MST_KEY varchar(30),
	IN A_OUT_KEY varchar(30),
	IN A_LOT_NO varchar(30),
	IN A_OUT_DATE DATETIME,
	IN A_CUST_CODE varchar(30),
	IN A_ITEM_CODE varchar(30),
	IN A_EX_RATE decimal(20,5),
	IN A_QTY decimal(20,4),
	IN A_COST decimal(20,4),
	IN A_ORDER_KEY varchar(30),
	IN A_RMK varchar(100),
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
	declare V_WARE_CODE bigint(20);
	declare V_IO_GUBN bigint(20);
	declare V_IO_GUBN_OUT bigint(20);
	declare V_IO_GUBN_PRE bigint(20);
	declare V_AMT decimal(20,4);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
  
  	# 수불 처리
	set V_SUBUL_KEY = concat('TB_OUT_DET_LOT-', A_OUT_MST_KEY, A_SET_NO, '-', A_LOT_NO);
	set V_TABLE_NAME = 'TB_OUT_DET_LOT';

	set V_AMT = A_QTY * A_COST;

	/*if new.PRE_STOCK_KIND = 151920 then
		set V_PRE_STOCK_YN = 'N';
	else
		set V_PRE_STOCK_YN = 'Y';
	end if;*/

	set V_IO_GUBN_PRE = 174051; # 선점출고 
	set V_IO_GUBN_OUT = 174052; # 선점출고예정
	set V_IO_GUBN = 34305; # 출고수불
	
	select B.WARE_CODE into V_WARE_CODE
	from tb_order_det A
		inner join tb_order_mst B on (A.COMP_ID = B.COMP_ID and A.ORDER_MST_KEY = B.ORDER_MST_KEY)
	where A.COMP_ID = A_COMP_ID and A.ORDER_KEY = A_ORDER_KEY;

	select ITEM_KIND into V_ITEM_KIND from tb_item_code where ITEM_CODE = A_ITEM_CODE;
	
	#선점 수불 생성 # 1:선점재고입고 , 2:선점재고출고 , 3:선점재고 출고예정차감 , 4:선점재고 출고예정    3번처리하고 2번 처리해야 재고부족오류 발생 안함 
	call SP_SUBUL_ORDER_CREATE(
        A_COMP_ID, concat(V_SUBUL_KEY, '-3'), 'INSERT', date_format(A_SET_DATE,'%Y%m%d'), '3', V_WARE_CODE, V_ITEM_KIND, A_ITEM_CODE, A_LOT_NO,
		V_IO_GUBN_OUT, A_QTY, V_TABLE_NAME, concat(A_OUT_MST_KEY, A_SET_NO), A_CUST_CODE, A_ORDER_KEY,
		A_SYS_ID, A_SYS_EMP_NO, 
		N_RETURN, V_RETURN);

  	if N_RETURN != 0 then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = V_RETURN;
  	end if;
  
	#선점 수불 생성  # 1:선점재고입고 , 2:선점재고출고 , 3:선점재고 출고예정차감 , 4:선점재고 출고예정
	call SP_SUBUL_ORDER_CREATE(
        A_COMP_ID, concat(V_SUBUL_KEY, '-2'), 'INSERT', date_format(A_SET_DATE,'%Y%m%d'), '2', V_WARE_CODE, V_ITEM_KIND, A_ITEM_CODE, A_LOT_NO,
		V_IO_GUBN_PRE, A_QTY, V_TABLE_NAME, concat(A_OUT_MST_KEY, A_SET_NO), A_CUST_CODE, A_ORDER_KEY,
		A_SYS_ID, A_SYS_EMP_NO, 
		N_RETURN, V_RETURN);

  	if N_RETURN != 0 then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = V_RETURN;
  	end if;

	#일반수불		입출고 구분의 경우 제품만 제품으로 / 상품, 원자재, 부자재 재료로 구분 값으로 넣는다
	call SP_SUBUL_CREATE(
		A_COMP_ID, V_SUBUL_KEY, 'INSERT', date_format(A_SET_DATE,'%Y%m%d'), '2', V_WARE_CODE, V_ITEM_KIND, A_ITEM_CODE, A_LOT_NO, 100, 
		V_IO_GUBN, A_QTY, A_COST, V_AMT, V_TABLE_NAME, concat(A_OUT_MST_KEY, A_SET_NO), 'Y', A_EX_RATE, '', A_CUST_CODE, 
		V_PRE_STOCK_YN, date_format(A_SET_DATE,'%Y%m%d'), A_ORDER_KEY, V_PRE_STOCK_YN, 'Y', 'Y', 
		A_SYS_ID, A_SYS_EMP_NO, 
		N_RETURN, V_RETURN);
  	
  	if N_RETURN != 0 then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = V_RETURN;
  	end if;
  
	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	INSERT INTO tb_out_det_lot 
	  		(COMP_ID,
			SET_DATE,
			SET_SEQ,
			SET_NO,
			OUT_MST_KEY,
			OUT_KEY,
			LOT_NO,
			OUT_DATE,
			ITEM_CODE,
			QTY,
			RMK,
			SYS_ID,
			SYS_EMP_NO,
			SYS_DT,
			UPD_ID,
			UPD_EMP_NO,
			UPD_DT)
     VALUES(A_COMP_ID,
			date_format(A_SET_DATE,'%Y%m%d'),
			A_SET_SEQ,
			A_SET_NO,
			A_OUT_MST_KEY,
			concat(A_OUT_MST_KEY, A_SET_NO),
			A_LOT_NO,
			date_format(A_OUT_DATE,'%Y%m%d'),
			A_ITEM_CODE,
			A_QTY,
			A_RMK,
			A_SYS_ID,
			A_SYS_EMP_NO,
			SYSDATE(),
			A_SYS_ID,
			A_SYS_EMP_NO,
			SYSDATE());
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end