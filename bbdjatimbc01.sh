#!/bin/bash
export DISPLAY=":0"


NOW=$(date -d "1 day ago" '+%Y%m')
bbdtable='bbd'$NOW'jatim_bc01'
NOW2=$(date -d "1 day ago" '+%m%Y')
bbd='HLR.01'$NOW2'*'

HOST='10.2.116.154'   # change the ipaddress accordingly
USER='dataint'   # username also change
PASSWD='geneva2005'    # password also change

sftp dataint@10.2.116.154 << !
   cd BILLING_01/BBD/REGIONAL06
   mget $bbd
   bye
!

command='/apps/mysql/mysql56/bin/mysql'

gunzip *.BBD.gz
sed 's/\t/ /g' *.BBD > bbd.txt

$command -u billco -pBillco2018  -h 10.65.181.46 -P 3307 -D billco --local-infile <<EOF

CREATE TABLE if not exists $bbdtable (
       CUSTOMER_I varchar(20) DEFAULT NULL,
           BA_ID varchar(20) DEFAULT NULL,
           ACCOUNT varchar(20) DEFAULT NULL,
           LEGACY_ACC varchar(20) DEFAULT NULL,
          MSISDN varchar(20) DEFAULT NULL,
  IMONTH varchar(2) DEFAULT NULL,
  IYEAR varchar(4) DEFAULT NULL,
  CALL_DATE varchar(9) DEFAULT NULL,
  CALL_TIME varchar(8) DEFAULT NULL,
  ORIGIN varchar(40) DEFAULT NULL,
  DIALLED_DIGIT varchar(17) DEFAULT NULL,
  DESTINATION varchar(40) DEFAULT NULL,
  DURATION varchar(8) DEFAULT NULL,
  DISCOUNTED_CHARGES varchar(19) DEFAULT NULL,
  	   ORIGINAL_CHARGE varchar(20) DEFAULT NULL,
  	   DISCOUNT varchar(20) DEFAULT NULL,
  	   EVENT_TYPE varchar(20) DEFAULT NULL,
  	   COST_BAND_NAME varchar(40) DEFAULT NULL,
  	   LACCEL_ID varchar(20) DEFAULT NULL,
  	   CURRENT_PACKAGE varchar(20) DEFAULT NULL,
  	   SUPPLIED_COST varchar(20) DEFAULT NULL,
  	   DISCOUNT_ID varchar(20) DEFAULT NULL,
  	   CHARGE_BEFORE_TAX varchar(20) DEFAULT NULL,
  	   TAX_AMOUNT varchar(20) DEFAULT NULL,
  	   CHARGE_AFTER_TAX varchar(20) DEFAULT NULL,
   KEY account (MSISDN),
  KEY MSISDN (MSISDN)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='latin1_swedish_ci';


LOAD DATA local INFILE 'bbd.txt'
    INTO TABLE $bbdtable
	FIELDS	 ESCAPED BY ''	
	  (@row)
       set CUSTOMER_I = TRIM(SUBSTR(@row,1,12)),
           BA_ID = TRIM(SUBSTR(@row,13,12)),
           ACCOUNT = TRIM(SUBSTR(@row,25,20)),
           LEGACY_ACC = TRIM(SUBSTR(@row,45,20)),
	   MSISDN = TRIM(SUBSTR(@row,65,15)),
  	   IMONTH = TRIM(SUBSTR(@row,80,2)),
  	   IYEAR = TRIM(SUBSTR(@row,82,4)),
  	   CALL_DATE = TRIM(SUBSTR(@row,86,9)),
  	   CALL_TIME = TRIM(SUBSTR(@row,95,8)),
  	   ORIGIN = TRIM(SUBSTR(@row,103,40)),
  	   DIALLED_DIGIT = TRIM(SUBSTR(@row,143,17)),
  	   DESTINATION = TRIM(SUBSTR(@row,160,40)),
  	   DURATION = TRIM(SUBSTR(@row,200,8)),
  	   DISCOUNTED_CHARGES = TRIM(SUBSTR(@row,208,19)),
  	   ORIGINAL_CHARGE = TRIM(SUBSTR(@row,227,19)),
  	   DISCOUNT = TRIM(SUBSTR(@row,246,19)),
  	   EVENT_TYPE = TRIM(SUBSTR(@row,265,2)),
  	   COST_BAND_NAME = TRIM(SUBSTR(@row,267,40)),
  	   LACCEL_ID = TRIM(SUBSTR(@row,307,11)),
  	   CURRENT_PACKAGE = TRIM(SUBSTR(@row,318,15)),
  	   SUPPLIED_COST = TRIM(SUBSTR(@row,333,19)),
  	   DISCOUNT_ID = TRIM(SUBSTR(@row,352,100)),
  	   CHARGE_BEFORE_TAX = TRIM(SUBSTR(@row,452,19)),
  	   TAX_AMOUNT = TRIM(SUBSTR(@row,471,19)),
  	   CHARGE_AFTER_TAX = TRIM(SUBSTR(@row,490,19));
EOF


rm *.BBD
rm bbd.txt


