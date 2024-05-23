CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD009$GET_MOLD_RACK_DIV`(
	IN `A_DATA_ID` BIGINT(20),
	IN `A_LANG` VARCHAR(100),
	OUT `N_RETURN` INT,
	OUT `V_RETURN` VARCHAR(4000)
)
PROC:BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION 
 BEGIN
	SET N_RETURN = -1;
 	CALL USP_SYS_GET_ERRORINFO(V_RETURN);
 END;
	if A_LANG = '' THEN
		set A_LANG = 'ko';
	end if;
	
	select 
		  A.DATA_ID,
	      A_LANG LANG,
	      A.PATH,
	      A.CODE,
	      A.NAME,
	      A.FULL_PATH,
	      A.DESCRIPTION,
	      A.VAL1,
	      A.VAL2,
	      A.VAL3,
	      A.VAL4,
	      A.VAL5,
	      A.VAL6,
	      A.VAL7,
	      A.VAL8,
	      A.VAL9,
	      A.VAL10,
	      A.DISP_SN,
	      A.USE_YN,
	      A.MODI_KEY,
	      A.PARENT
	from SYS_DATA A
	where A.path = 'cfg.dist.rack.mold'
	  and case 
			  when A_DATA_ID != 0
			  then A.DATA_ID = A_DATA_ID
			  else A.DATA_ID like '%'
		  end 
	;

	SET N_RETURN = 0;
	SET V_RETURN = 'MSG_COM_001';
END