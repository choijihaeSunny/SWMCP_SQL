-- swmcp.tb_input_etc_mst definition

CREATE TABLE `tb_input_etc_mst` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `SET_DATE` varchar(8) NOT NULL COMMENT '등록일자',
  `SET_SEQ` varchar(4) NOT NULL COMMENT '등록순번',
  `INPUT_ETC_MST_KEY` varchar(30) NOT NULL COMMENT '기타입고MST번호',
  `INPUT_DATE` varchar(8) DEFAULT NULL COMMENT '입고일자',
  `CUST_CODE` varchar(10) DEFAULT NULL COMMENT '거래처',
  `EMP_NO` varchar(10) DEFAULT NULL COMMENT '담당자',
  `DEPT_CODE` varchar(10) DEFAULT NULL COMMENT '요청부서',
  `SHIP_INFO` varchar(30) DEFAULT NULL COMMENT '호선정보',
  `PJ_NO` varchar(30) DEFAULT NULL COMMENT '프로젝트NO',
  `PJ_NAME` varchar(50) DEFAULT NULL COMMENT '프로젝트명',
  `RMKS` varchar(100) DEFAULT NULL COMMENT '특이사항',
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
  PRIMARY KEY (`COMP_ID`,`INPUT_ETC_MST_KEY`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='구매기타MST';