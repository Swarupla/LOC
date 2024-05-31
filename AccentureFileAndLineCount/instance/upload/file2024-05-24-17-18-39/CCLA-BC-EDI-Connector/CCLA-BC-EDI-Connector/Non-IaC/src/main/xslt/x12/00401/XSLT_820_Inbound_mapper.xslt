<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:input="urn:my-input-variables"
                xmlns:xslt="http://xml.apache.org/xslt" 
                xmlns:ns0="http://schemas.microsoft.com/BizTalk/EDI/X12/2006"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" 
                xmlns:userJScript="http://schemas.microsoft.com/BizTalk/2003/userJScript"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                exclude-result-prefixes="msxsl var userJScript">
    
    <xsl:output method="text" indent="yes"/>
    <xsl:param name="input:participants"/>
    <xsl:param name="input:zfFilterID"/>
    <xsl:param name="input:sourcePartnQualf"/>
    <xsl:param name="input:sourcePartnerId"/>
    <xsl:param name="input:sourceNodeId"/>
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
				return inputDateFormat ? ( inputTimeFormat ? inputDateFormat.substring(0, 4)+"-"+inputDateFormat.substring(4,6)+"-"+inputDateFormat.substring(6, 8)+"T"+inputTimeFormat.substring(0, 2)+":" +inputTimeFormat.substring(2, 4) +":"+ inputTimeFormat.substring(4, 6) +".000Z" : inputDateFormat.substring(0, 4)+"-"+inputDateFormat.substring(4,6)+"-"+inputDateFormat.substring(6, 8) + "T00:00:00.000Z") : "";
            }


		]]>
    </msxsl:script>
    <xsl:template match="/ns0:X12_00401_820">
        {
                "method": "POST",
                "url": "<xsl:value-of select="$input:host"/>/api/payments",
        "payload": [
            {
               "txnGroup": {
						"participants": [
							<xsl:value-of select="$input:participants"/>
						]
				},
                <xsl:if test="ns0:TRN/TRN01 = 1">
                  "paymentNumber": "<xsl:value-of select="ns0:TRN/TRN02"/>",  
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="ns0:BPR/BPR04 = 'CHK'">
                        "paymentType": "<xsl:value-of select="'CHECK'"/>",
                    </xsl:when>
                    <xsl:when test="ns0:BPR/BPR04 = 'CWT'">
                        "paymentType": "<xsl:value-of select="'WIRE'"/>",
                    </xsl:when>
                    <xsl:when test="ns0:BPR/BPR04 = 'ZZZ'">
                        "paymentType": "<xsl:value-of select="'OTHER'"/>",
                    </xsl:when>
                    <xsl:when test="ns0:BPR/BPR04 = 'CCH'">
                        "paymentType": "<xsl:value-of select="'RECEIPT'"/>",
                    </xsl:when>
                </xsl:choose>
                <xsl:variable name="debitCreditFlag" select="ns0:BPR/BPR03"/>
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
								<xsl:for-each select="ns0:REF_2">
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
                <xsl:if test="ns0:CUR/CUR01 = 'BY'">
                "currency": "<xsl:value-of select="ns0:CUR/CUR02"/>",
                </xsl:if>
                "amount": [
                    <xsl:if test="ns0:BPR/BPR01 = 'C'">
                        {
                        "type": "PAID_AMT",
                        "value": <xsl:value-of select="ns0:BPR/BPR02"/>
                    }
                    </xsl:if>
                    
                ],
                "dtm": [
                   <xsl:for-each select="ns0:DTM">
							{
                                    "dateQualf": "<xsl:value-of select="DTM01"/>",
                                    "date": <xsl:call-template name="dtmDate"><xsl:with-param name="dtmObj" select="." /></xsl:call-template>
                            },
					</xsl:for-each>
                ],
                "ref": [
                   {
							"idQualf": "ZF",
							"id": "<xsl:value-of select="$input:zfFilterID"/>",
							"desc": ""
						},
						<xsl:for-each select="ns0:REF">
							<xsl:choose>
								<xsl:when test="REF01 = 'MA'">
									{
									"idQualf": "<xsl:text>AS</xsl:text>",
									"id": "<xsl:value-of select="REF02"/>",
									"desc": "<xsl:value-of select="REF03"/>"
									},
								</xsl:when>
								<xsl:when test="REF01 = '8H'">
									{
									"idQualf": "<xsl:text>CK</xsl:text>",
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
                "lineItems": [
                <xsl:for-each select="ns0:ENTLoop1">
                    {
                        "line": "<xsl:value-of select="ns0:ENT/ENT01"/>",
                        <xsl:for-each select="ns0:RMRLoop1">
                            "amount": [
                            {
                                "type": "PAID_AMT",
                                "debitCreditFlag": "<xsl:value-of select="$debitCreditFlag"/>",
                                "value": <xsl:value-of select="ns0:RMR/RMR04"/>
                            }
                        ],
                        "dtm": [
                           <xsl:for-each select="ns0:DTM_7">
							{
								"dateQualf": "<xsl:value-of select="DTM01"/>",
								"date": <xsl:call-template name="dtmDate"><xsl:with-param name="dtmObj" select="." /></xsl:call-template>
							},
						</xsl:for-each>
                        ],
                        "ref": [
                            {
                                        "idQualf": "ZF",
                                        "id": "<xsl:value-of select="$input:zfFilterID"/>",
                                        "desc": ""
                                    },
                                    <xsl:for-each select="ns0:REF_7">
                                        <xsl:choose>
                                            <xsl:when test="REF01 = 'MA'">
                                                {
                                                "idQualf": "<xsl:text>AS</xsl:text>",
                                                "id": "<xsl:value-of select="REF02"/>",
                                                "desc": "<xsl:value-of select="REF03"/>"
                                                },
                                            </xsl:when>
                                            <xsl:when test="REF01 = '8H'">
                                                {
                                                "idQualf": "<xsl:text>CK</xsl:text>",
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
                        ]
                        </xsl:for-each>
                    },
                </xsl:for-each>
                ]
            }
        ]
    }
    </xsl:template>
    <xsl:template name="dtmHeader">
        <xsl:param name = "dtmArr" />
        [
            <xsl:for-each select="$dtmArr">
                <xsl:if test="DTM02 != ''">
                {
                    "dateQualf": "<xsl:value-of select="DTM01"/>",
                    "date": <xsl:call-template name="dtmDate"><xsl:with-param name="dtmObj" select="." /></xsl:call-template>
                },
                </xsl:if>
            </xsl:for-each>
        ]
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