-- swmcp.tb_mold_forder definition

CREATE TABLE `tb_mold_forder` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `SET_DATE` varchar(8) NOT NULL COMMENT '등록일자',
  `SET_SEQ` varchar(4) NOT NULL COMMENT '등록순번',
  `SET_NO` varchar(4) NOT NULL COMMENT 'NO',
  `MOLD_MORDER_KEY` varchar(30) NOT NULL COMMENT '금형발주번호',
  `MOLD_CODE` varchar(20) NOT NULL COMMENT '금형코드',
  `CUST_CODE` varchar(10) DEFAULT NULL COMMENT '거래처',
  `QTY` decimal(10,0) DEFAULT 0 COMMENT '발주수량',
  `DELI_DATE` varchar(8) DEFAULT NULL COMMENT '납기일자',
  `COST` decimal(16,4) DEFAULT 0.0000 COMMENT '단가',
  `AMT` decimal(16,4) DEFAULT 0.0000 COMMENT '금액',
  `EMP_NO` varchar(10) DEFAULT NULL COMMENT '담당자',
  `DEPT_CODE` varchar(10) DEFAULT NULL COMMENT '담당부서',
  `IN_QTY` decimal(10,0) DEFAULT 0 COMMENT '입고수량',
  `CALL_KIND` varchar(10) DEFAULT NULL COMMENT '호출구분',
  `CALL_KEY` varchar(30) DEFAULT NULL COMMENT '호출KEY',
  `RMK` varchar(100) DEFAULT NULL COMMENT '비고',
  `TEMP1` varchar(10) DEFAULT NULL COMMENT '임시01',
  `TEMP2` varchar(10) DEFAULT NULL COMMENT '임시02',
  `TEMP3` varchar(10) DEFAULT NULL COMMENT '임시03',
  `TEMP4` varchar(10) DEFAULT NULL COMMENT '임시04',
  `TEMP5` varchar(10) DEFAULT NULL COMMENT '임시05',
  `SYS_EMP_NO` varchar(10) NOT NULL COMMENT '등록사번',
  `SYS_ID` varchar(30) NOT NULL COMMENT '등록ID',
  `SYS_DATE` timestamp NULL DEFAULT current_timestamp() COMMENT '등록일자',
  `UPD_EMP_NO` varchar(10) DEFAULT NULL COMMENT '수정사번',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정ID',
  `UPD_DATE` timestamp NULL DEFAULT current_timestamp() COMMENT '수정일자',
  PRIMARY KEY (`MOLD_MORDER_KEY`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='금형발주관리';