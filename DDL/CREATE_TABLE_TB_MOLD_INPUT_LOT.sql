-- swmcp.tb_mold_input_lot definition

CREATE TABLE `tb_mold_input_lot` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `SET_DATE` varchar(8) NOT NULL COMMENT '등록일자',
  `SET_SEQ` varchar(4) NOT NULL COMMENT '등록순번',
  `SET_NO` varchar(4) NOT NULL COMMENT 'NO',
  `MOLD_INPUT_KEY` varchar(30) NOT NULL COMMENT '금형입고번호',
  `MOLD_CODE` varchar(20) NOT NULL COMMENT '금형코드',
  `LOT_NO` varchar(30) NOT NULL COMMENT 'LOT NO',
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
  PRIMARY KEY (`COMP_ID`, `MOLD_INPUT_KEY`, `LOT_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='금형입고관리';