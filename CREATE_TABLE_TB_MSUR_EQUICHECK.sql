CREATE TABLE `tb_msur_equicheck` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장',
  `IDX` int(11) NOT NULL AUTO_INCREMENT COMMENT '저장번호',
  `EQUI_CODE` varchar(20) NOT NULL COMMENT '관리번호',
  `CHECK_ITEM` varchar(10) NOT NULL COMMENT '점검항목',
  `CYCLE` decimal(3,0) DEFAULT 0 COMMENT '점검주기(월)',
  `FINAL_DATE` timestamp NULL DEFAULT current_timestamp() COMMENT '최종점검일',
  `NEXT_DATE` timestamp NULL DEFAULT current_timestamp() COMMENT '차기점검일',
  `CHECK_DEPT` varchar(10) DEFAULT NULL COMMENT '점검기관',
  `ETC_RMK` varchar(200) DEFAULT NULL COMMENT '비고',
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
  PRIMARY KEY (`COMP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='검사점검항목등록';