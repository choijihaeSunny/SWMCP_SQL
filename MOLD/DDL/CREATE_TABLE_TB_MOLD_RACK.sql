-- swmcp.tb_mold_rack definition

CREATE TABLE `tb_mold_rack` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `RACK_CODE` varchar(20) NOT NULL COMMENT '창고랙코드',
  `RACK_NAME` varchar(30) NOT NULL COMMENT '창고랙이름',
  `RACK_DIV` bigint(20) NOT NULL COMMENT '랙구분',
  `FLOOR` varchar(3) NOT NULL COMMENT '층',
  `ROOM` varchar(3) NOT NULL COMMENT '칸',
  `SPEC` bigint(20) NOT NULL COMMENT '용량',
  `SIZE_R` decimal(10,0) DEFAULT 0 COMMENT '가로(cm)',
  `SIZE_V` decimal(10,0) DEFAULT 0 COMMENT '세로(cm)',
  `SIZE_H` decimal(10,0) DEFAULT 0 COMMENT '높이(cm)',
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
  PRIMARY KEY (`COMP_ID`,`RACK_CODE`,`RACK_NAME`,`RACK_DIV`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='금형창고위치';