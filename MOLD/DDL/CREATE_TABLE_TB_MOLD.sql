-- swmcp.tb_mold definition

CREATE TABLE `tb_mold` (
  `MOLD_CODE` varchar(20) NOT NULL COMMENT '금형코드',
  `CLASS1` bigint(20) NOT NULL COMMENT '대분류',
  `CLASS2` bigint(20) NOT NULL COMMENT '중분류',
  `CLASS_SEQ` varchar(4) NOT NULL COMMENT '순번',
  `MOLD_NAME` varchar(50) NOT NULL COMMENT '금형명',
  `MOLD_SPEC` varchar(50) NOT NULL COMMENT '금형규격',
  `LOT_YN` bigint(20) DEFAULT NULL COMMENT 'LOT관리여부(Y/N)',
  `STOCK_SAFE` decimal(10,0) DEFAULT NULL COMMENT '안전재고',
  `CUST_CODE` varchar(10) DEFAULT NULL COMMENT '대표거래처',
  `ITEM_UNIT` decimal(10,0) DEFAULT 0 COMMENT '제품단증',
  `USE_YN` varchar(1) DEFAULT 'Y' COMMENT '사용여부',
  `RMK` varchar(100) DEFAULT NULL COMMENT '비고',
  `CODE_PRE` varchar(30) DEFAULT NULL COMMENT '이전코드',
  `WARE_POS` varchar(10) DEFAULT NULL COMMENT '창고위치',
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
  PRIMARY KEY (`MOLD_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='금형코드관리';