<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:input="urn:my-input-variables"
                xmlns:xslt="http://xml.apache.org/xslt"
                xmlns:ns0="http://schemas.microsoft.com/BizTalk/EDI/X12/2006"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var"
                xmlns:userJScript="http://schemas.microsoft.com/BizTalk/2003/userJScript"
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				exclude-result-prefixes="msxsl var userJScript"
	>
	<xsl:output method="text" indent="yes"/>
	<xsl:param name="input:participants"/>
	<xsl:param name="input:zfFilterID"/>
	<xsl:param name="input:sourcePartnQualf"/>
	<xsl:param name="input:sourcePartnerId"/>
	<xsl:param name="input:sourceNodeId"/>
	<xsl:param name="input:vendorPartyNodeId"/>
	<xsl:param name="input:shipToNodeId"/>
	<xsl:param name="input:shipFromNodeId"/>
	<xsl:param name="input:billToNodeId"/>
	<xsl:param name="input:host"/>
	<msxsl:script language="JScript" implements-prefix="userJScript">
        <![CDATA[
			var isPODocumentDate = 0;
			function updatePODocumentDateFlag(){
				isPODocumentDate = 1;
				return isPODocumentDate
			}
			function getIsPODocumentDateFlag(){
				return isPODocumentDate;
			}
			function dateFormated(inputDateFormat){
				return inputDateFormat ? inputDateFormat.substring(0, 4)+"-"+inputDateFormat.substring(4,6)+"-"+inputDateFormat.substring(6, 8)+"T00:00:00.000Z" : "";
            }

			function dateFormatedDTM(inputDateFormat , inputTimeFormat){
				return inputDateFormat ? inputDateFormat.substring(0, 4)+"-"+inputDateFormat.substring(4,6)+"-"+inputDateFormat.substring(6, 8)+"T"+inputTimeFormat.substring(0, 2)+":" +inputTimeFormat.substring(2, 4) +":"+ inputTimeFormat.substring(4, 6) +".000Z" : "";
            }


		]]>
    </msxsl:script>
	<xsl:template match="/ns0:X12_00401_850">
	{
	<xsl:choose>
		<xsl:when test="ns0:BEG/BEG01 = '00'">
			"method": "POST",
			"url": "<xsl:value-of select="$input:host"/>/api/purchaseorders",
			"payload": [
				{
					"txnGroup": {
						"participants": [
							<xsl:value-of select="$input:participants"/>
						]
					},
					<xsl:choose>
						<xsl:when test="ns0:BEG/BEG02 = 'LP'">
							"orderType": "SA",			
						</xsl:when>
						<xsl:otherwise>
							"orderType": "<xsl:value-of select="ns0:BEG/BEG02" />",			
						</xsl:otherwise>
					</xsl:choose>
					"orderNumber": "<xsl:value-of select="ns0:BEG/BEG03" />",
					"currency": "<xsl:value-of select="ns0:CUR/CUR02"/>",
					"dtm": [		
						<xsl:for-each select="ns0:DTM">
							<xsl:if test="DTM01 = '004'">
								<xsl:variable name="isPODocumentDate" select='userJScript:updatePODocumentDateFlag()'/>
							</xsl:if>
							{
							"dateQualf": "<xsl:value-of select="DTM01"/>",
							"date": <xsl:call-template name="dtmDate"><xsl:with-param name="dtmObj" select="." /></xsl:call-template>
							},
						</xsl:for-each>
						<xsl:if test="userJScript:getIsPODocumentDateFlag() = '0'">
							{
							"dateQualf": "004",
							"date": "<xsl:value-of select='userJScript:dateFormated(string(ns0:BEG/BEG05))' />"
							},
						</xsl:if>
					],
					"qty": [
						<xsl:for-each select="ns0:CTTLoop1">
							<xsl:if test="ns0:CTT/CTT02 != ''">
								{
								"type": "PO_QTY",
								"value": <xsl:value-of select="ns0:CTT/CTT02"/>,
								"uom": "<xsl:value-of select="ns0:CTT/CTT04"/>"
								},
							</xsl:if>
						</xsl:for-each>
					],
					"prices": [
						<xsl:for-each select="ns0:CTTLoop1">
							<xsl:if test="ns0:AMT_3/AMT01 = 'TT'">
								{
								"type": "AMOUNT",
								"value": <xsl:value-of select="ns0:AMT_3/AMT02"/>
								},
							</xsl:if>
						</xsl:for-each>
					],
					"paymentTerms": {
						<!-- Terms - Out of scope -->
						"terms":  "<xsl:value-of select="ns0:ITD/ITD07" />",
						<xsl:if test="ns0:ITD/ITD06 != ''">
						"termsDate": "<xsl:value-of select='userJScript:dateFormated(string(ns0:ITD/ITD06))' />",
						</xsl:if>
						<xsl:if test="ns0:ITD/ITD02 != ''">
						"termsBasisDate": <xsl:value-of select="ns0:ITD/ITD02" />,
						</xsl:if>  
						"termsDescription": "<xsl:value-of select="ns0:ITD/ITD12" />",
						"discountDetails": [
							{
							"termsDiscount": <xsl:value-of select="ns0:ITD/ITD03" />,
							"termsDays": <xsl:value-of select="ns0:ITD/ITD05" />,
							<xsl:if test="ns0:ITD/ITD04 != ''">
							"termsDiscountDate": "<xsl:value-of select='userJScript:dateFormated(string(ns0:ITD/ITD04))' />"
							</xsl:if>
							}
						]
					},
					<!-- TODO : To be updated for DPU,DAP once confirmed -->
					<xsl:if test="ns0:FOB/FOB04 = '01'">
					"incoTerms": {
                        <xsl:choose>
                                        <xsl:when test="ns0:FOB/FOB05 = 'DAP'">
                                            "incoTerms1": "<xsl:value-of select="'DAP'" />",
                                        </xsl:when>
                                        <xsl:when test="ns0:FOB/FOB05 = 'ZZZ'">
                                            "incoTerms1": "<xsl:value-of select="'DPU'" />",
                                        </xsl:when>
                                        <xsl:otherwise>
                                            "incoTerms1": "<xsl:value-of select="ns0:FOB/FOB05" />",
                                            </xsl:otherwise>
                                    </xsl:choose>
						
						"incoTerms2": "<xsl:value-of select="ns0:FOB/FOB07" />"
					}, 
					 </xsl:if>
					"ref": [
						{
							"idQualf": "ZF",
							"id": "<xsl:value-of select="$input:zfFilterID"/>",
							"desc": ""
						},
						<xsl:for-each select="ns0:REF">
							<xsl:choose>
								<xsl:when test="REF01 = 'LD'">
									{
									"idQualf": "<xsl:text>ZL</xsl:text>",
									"id": "<xsl:value-of select="REF02"/>",
									"desc": "<xsl:value-of select="REF03"/>"
									},
								</xsl:when>
								<xsl:when test="REF01 = 'PE'">
									{
									"idQualf": "<xsl:text>ZP</xsl:text>",
									"id": "<xsl:value-of select="REF02"/>",
									"desc": "<xsl:value-of select="REF03"/>"
									},
								</xsl:when>
								<xsl:when test="REF01 = 'CT'">
									{
									"idQualf": "<xsl:text>ZC</xsl:text>",
									"id": "<xsl:value-of select="REF02"/>",
									"desc": "<xsl:value-of select="REF03"/>"
									},
								</xsl:when>
								<xsl:when test="REF01 = 'DD'">
									{
									"idQualf": "<xsl:text>ZD</xsl:text>",
									"id": "<xsl:value-of select="REF02"/>",
									"desc": "<xsl:value-of select="REF03"/>"
									},
								</xsl:when>
								<xsl:otherwise>
									{
									"idQualf": "<xsl:value-of select="REF01"/>",
									"id": "<xsl:value-of select="REF02"/>",
									"desc": "<xsl:value-of select="REF03"/>"
									},
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					],
					"parties": [
						{
						"partnQualf": "<xsl:value-of select="$input:sourcePartnQualf"/>",
						"partnerId": "<xsl:value-of select="$input:sourcePartnerId"/>",
						"nodeId": "<xsl:value-of select="$input:sourceNodeId"/>"
						},
						<xsl:for-each select="ns0:N1Loop1">
								{
								"partnQualf": "<xsl:value-of select="ns0:N1/N101"/>",
								"partnerId": "<xsl:value-of select="ns0:N1/N104"/>",
								<!-- <xsl:choose>
									<xsl:when test="ns0:N1/N101 = 'VN'">
										"nodeId": "<xsl:value-of select="$input:vendorPartyNodeId"/>",
									</xsl:when>
									<xsl:when test="ns0:N1/N101 = 'ST'">
										"nodeId": "<xsl:value-of select="$input:shipToNodeId"/>",
									</xsl:when>
									<xsl:when test="ns0:N1/N101 = 'BT'">
										"nodeId": "<xsl:value-of select="$input:billToNodeId"/>",
									</xsl:when>
									<xsl:when test="ns0:N1/N101 = 'SF'">
										"nodeId": "<xsl:value-of select="$input:shipFromNodeId"/>",
									</xsl:when>
									<xsl:otherwise>
										"nodeId": "",
									</xsl:otherwise>
								</xsl:choose> -->
								<xsl:for-each select="ns0:REF_3">
									<xsl:if test="REF01 = '1W'">
											"nodeId": "<xsl:value-of select="REF02"/>",
									</xsl:if>
								</xsl:for-each>
						<xsl:choose>
							<xsl:when test="ns0:N1/N102 != ''">
								"name1": "<xsl:value-of select="ns0:N1/N102"/>",
							</xsl:when>
							<xsl:otherwise>
								"name1": "<xsl:value-of select="ns0:N2/N201"/>",
							</xsl:otherwise>
						</xsl:choose>
								"name2": "<xsl:value-of select="ns0:N2/N202"/>",
						<xsl:choose>
							<xsl:when test="ns0:N1/N102 != ''">
								"description": "<xsl:value-of select="ns0:N1/N102"/>",
							</xsl:when>
							<xsl:otherwise>
								"description": "<xsl:value-of select="ns0:N2/N201"/>",
							</xsl:otherwise>
						</xsl:choose>
								"address": {
								"address1": "<xsl:value-of select="ns0:N3/N301"/>",
								"address2": "<xsl:value-of select="ns0:N3/N302"/>",
								"houseNum": "",
								"city": "<xsl:value-of select="ns0:N4/N401"/>",
								"state": "<xsl:value-of select="ns0:N4/N402"/>",
								"zip": "<xsl:value-of select="ns0:N4/N403"/>",
								"country": "<xsl:value-of select="ns0:N4/N404"/>"
								}
								},
						</xsl:for-each>
					],
					"lineItems" :  [
						<xsl:for-each select="ns0:PO1Loop1">
						{
						"line": "<xsl:value-of select="ns0:PO1/PO101"/>",
						"dtm": [
						<xsl:for-each select="ns0:DTM_7">
							{
								"dateQualf": "<xsl:value-of select="DTM01"/>",
								"date":  <xsl:call-template name="dtmDate"><xsl:with-param name="dtmObj" select="." /></xsl:call-template>
							},
						</xsl:for-each>
							],
						<xsl:if test="ns0:PO1/PO102 != ''">
							"qty": [
							{
							"type": "PO_QTY",
							"value": <xsl:value-of select="ns0:PO1/PO102"/>,
							"uom": "<xsl:value-of select="ns0:PO1/PO103"/>"
							}
							],
						</xsl:if>
						"prices": [
						<xsl:for-each select="ns0:CTPLoop1">
							<xsl:if test="ns0:CTP_2/CTP02 = 'ACT'">
							{
							"type": "UNIT_PRICE",
							"value":<xsl:value-of select="ns0:CTP_2/CTP03"/>
							},
							</xsl:if>
						</xsl:for-each>
						<xsl:for-each select="ns0:AMTLoop2">
							<xsl:if test="ns0:AMT_2/AMT01 = 1">
							{
							"type": "AMOUNT",
							"value": <xsl:value-of select="ns0:AMT_2/AMT02"/>
							},
							</xsl:if>
						</xsl:for-each>
						],
						"product": [
							<xsl:for-each select="ns0:LIN_2">
								<xsl:if test="LIN02 = 'MG'">
									{
									"productQualf": "VP",
									"value": "<xsl:value-of select="LIN03"/>",
									"productDescription": ""
									},
								</xsl:if> 
								<xsl:if test="LIN04 = 'BP'">
									{
									"productQualf": "BP",
									"value": "<xsl:value-of select="LIN05"/>",
									"productDescription": ""
									},
								</xsl:if> 
								<xsl:if test="LIN06 = 'ZZ'">
									{
									"productQualf": "ZM",
									"value": "<xsl:value-of select="LIN07"/>",
									"productDescription": ""
									},
								</xsl:if> 
							</xsl:for-each>
						]
						},
						</xsl:for-each>
					]
					},
			]
		</xsl:when>
		<xsl:when test="ns0:BEG/BEG01 = '03'">
		<!-- TODO : Delete reason to be confirmed , Ignore BEG07 -->
			<xsl:variable name="deleteReason"><xsl:text>4</xsl:text>
			</xsl:variable>
			"method": "DELETE",
			<xsl:variable name="singleQuote">'</xsl:variable> 
			"url": "<xsl:value-of select="$input:host"/>/api/purchaseorders/<xsl:value-of select="ns0:BEG/BEG03"/>?participants=<xsl:value-of select="translate($input:participants, $singleQuote, '')" />&amp;deleteReason=<xsl:value-of select="$deleteReason"/>",
			"payload" : ""
		</xsl:when>
	</xsl:choose>
	
}
	</xsl:template>
	<xsl:template match="dtmObj" name="dtmDate">
        <xsl:choose>
            <xsl:when test="DTM03 != ''">
                <xsl:choose>
                    <xsl:when test="string-length(DTM03) = 4">
                        "<xsl:value-of select="substring(DTM02, 1, 4)"/>-<xsl:value-of select="substring(DTM02, 5, 2)"/>-<xsl:value-of select="substring(DTM02, 7, 2)"/>T<xsl:value-of select="substring(DTM03, 1, 2)"/>:<xsl:value-of select="substring(DTM03, 3, 2)"/>:00.000Z"
                    </xsl:when>
                    <xsl:when test="string-length(DTM03) = 6">
                        "<xsl:value-of select="substring(DTM02, 1, 4)"/>-<xsl:value-of select="substring(DTM02, 5, 2)"/>-<xsl:value-of select="substring(DTM02, 7, 2)"/>T<xsl:value-of select="substring(DTM03, 1, 2)"/>:<xsl:value-of select="substring(DTM03, 3, 2)"/>:<xsl:value-of select="substring(DTM03, 5, 2)"/>.000Z"
                    </xsl:when>
                    <xsl:when test="string-length(DTM03) > 6">
                        "<xsl:value-of select="substring(DTM02, 1, 4)"/>-<xsl:value-of select="substring(DTM02, 5, 2)"/>-<xsl:value-of select="substring(DTM02, 7, 2)"/>T<xsl:value-of select="substring(DTM03, 1, 2)"/>:<xsl:value-of select="substring(DTM03, 3, 2)"/>:<xsl:value-of select="substring(DTM03, 5, 2)"/>.000Z"
                    </xsl:when>
                    <xsl:otherwise>
                        "<xsl:value-of select="substring(DTM02, 1, 4)"/>-<xsl:value-of select="substring(DTM02, 5, 2)"/>-<xsl:value-of select="substring(DTM02, 7, 2)"/>T00:00:00.000Z"
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                "<xsl:value-of select="substring(DTM02, 1, 4)"/>-<xsl:value-of select="substring(DTM02, 5, 2)"/>-<xsl:value-of select="substring(DTM02, 7, 2)"/>T00:00:00.000Z"
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>