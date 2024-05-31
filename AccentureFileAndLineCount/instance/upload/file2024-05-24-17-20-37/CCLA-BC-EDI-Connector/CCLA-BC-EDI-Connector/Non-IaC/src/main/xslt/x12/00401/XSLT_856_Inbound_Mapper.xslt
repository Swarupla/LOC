<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:input="urn:my-input-variables"
                xmlns:xslt="http://xml.apache.org/xslt" 
                xmlns:ns0="http://schemas.microsoft.com/BizTalk/EDI/X12/2006"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" 
                xmlns:userJScript="http://schemas.microsoft.com/BizTalk/2003/userJScript">
    <xsl:output method="text" indent="yes"/>
    <xsl:param name="input:participants"/>
    <xsl:param name="input:shipmentType"/>
    <xsl:param name="input:zfFilterID"/>
    <xsl:param name="input:sourcePartnQualf"/>
    <xsl:param name="input:sourcePartnerId"/>
    <xsl:param name="input:sourceNodeId"/>
    <xsl:param name="input:host"/>
     <xsl:key name="lineKey" match="ns0:LIN" use="LIN01"/>
    <xsl:template match="/ns0:X12_00401_856">
    {
        <xsl:choose>
            <xsl:when test="ns0:BSN/BSN01 = '00'">
                "method": "POST",
                "url": "<xsl:value-of select="$input:host"/>/api/shipments",
                "payload": [
             {
                "txnGroup": {
                    "participants": [                        
                        <xsl:value-of select="$input:participants"/>
                    ]
                },
                "shipmentDetails": [
                    <xsl:for-each select="ns0:HLLoop1">
                        <xsl:for-each select="ns0:TD5">
                            <xsl:if test="(TD504 != '') or (TD512 != '')">
                            {
                                <xsl:choose>
                                    <xsl:when test="TD512 = 'G2'">
                                        "serviceLevel": "<xsl:value-of select="'S'" />",
                                    </xsl:when>
                                    <xsl:when test="TD512 = 'ES'">
                                        "serviceLevel": "<xsl:value-of select="'E'" />",
                                    </xsl:when>
                                </xsl:choose>
                                "mode": "<xsl:value-of select="TD504"/>"
                            },
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:for-each>
                ],
                "shipmentType": "<xsl:value-of select="$input:shipmentType"/>",
                "shipmentNumber": "<xsl:value-of select="ns0:BSN/BSN02"/>",
                <xsl:variable name="cooQualfArr" select="ns0:HLLoop1/ns0:SLN/SLN09"/>
                <xsl:variable name="cooArr" select="ns0:HLLoop1/ns0:SLN/SLN10"/>
                <xsl:if test="$cooQualfArr[1] = 'CH'">
                    "coo": "<xsl:value-of select="$cooArr[1]"/>",
                </xsl:if>
                "ref": [
                    {
                        "idQualf": "<xsl:value-of select="'ZF'" />",
                        "id": "<xsl:value-of select="$input:zfFilterID"/>",
                        "desc": ""
                    },
                    <xsl:for-each select="ns0:HLLoop1">
                    <xsl:variable name="HL03" select="ns0:HL/HL03"/>
                    <xsl:variable name="PRF" select="ns0:PRF"/>
                        <xsl:if test="ns0:HL/HL03 = 'O' and ns0:PRF != ''">
                            {
                                "idQualf": "<xsl:value-of select="'OP'" />",
                                "id": "<xsl:value-of select="ns0:PRF/PRF01"/>",
                                "desc": ""
                            },
                        </xsl:if>
                        <xsl:if test="ns0:HL/HL03 = 'S' or ns0:HL/HL03 = 'O'">
                           <xsl:for-each select="ns0:REF">
                                <xsl:choose>
                                    <xsl:when test="REF01 = '2I'">
                                    {
                                        "idQualf": "<xsl:value-of select="'LTN'" />",
                                        "id": "<xsl:value-of select="REF02"/>",
                                        "desc": "<xsl:value-of select="REF03"/>"
                                    },
                                    </xsl:when>
                                    <xsl:when test="REF01 = 'LI'">
                                    {
                                        "idQualf": "<xsl:value-of select="'CL'" />",
                                        "id": "<xsl:value-of select="REF02"/>",
                                        "desc": "<xsl:value-of select="REF03"/>"
                                    },
                                    </xsl:when>
                                    <xsl:when test="REF01 = 'PE'">
                                            {
                                                "idQualf": "<xsl:value-of select="'ZFP'" />",
                                                "id": "<xsl:value-of select="REF02"/>",
                                                "desc": "<xsl:value-of select="REF03"/>"
                                            },
                                    </xsl:when>
                                    <xsl:when test="REF01 = 'OP' and ($HL03 = 'O')">
                                        <xsl:choose>
                                            <xsl:when test="$PRF != ''">
                                            </xsl:when>
                                            <xsl:otherwise>
                                                {
                                                    "idQualf": "<xsl:value-of select="REF01"/>",
                                                    "id": "<xsl:value-of select="REF02"/>",
                                                    "desc": "<xsl:value-of select="REF03"/>"
                                                },
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    <xsl:if test="REF01 != 'OP'">
                                    {
                                        "idQualf": "<xsl:value-of select="REF01"/>",
                                        "id": "<xsl:value-of select="REF02"/>",
                                        "desc": "<xsl:value-of select="REF03"/>"
                                    },
                                    </xsl:if>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each> 
                        </xsl:if>
                        
                    </xsl:for-each>
                ],  
                
                "dtm": <xsl:call-template name="dtmHeader"><xsl:with-param name="dtmArr" select="ns0:DTM" /></xsl:call-template>,
                "parties": [
                    {
                        "partnQualf": "<xsl:value-of select="$input:sourcePartnQualf"/>",
                        "partnerId": "<xsl:value-of select="$input:sourcePartnerId"/>",
                        "nodeId": "<xsl:value-of select="$input:sourceNodeId"/>"
                    },
                    <xsl:for-each select="ns0:HLLoop1">
                        <xsl:if test="ns0:HL/HL03 = 'S'">
                            <xsl:for-each select="ns0:N1Loop1">
                            {
                                "partnQualf": "<xsl:value-of select="ns0:N1/N101"/>",
                                "partnerId": "<xsl:value-of select="ns0:N1/N104"/>",
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
                        </xsl:if>
                        
                    </xsl:for-each>
                ],
                "lineItems": [
                    <xsl:apply-templates select="ns0:HLLoop1/ns0:LIN[generate-id() = generate-id(key('lineKey', LIN01)[1])]"/>
                ],
                <!-- Set orders HL01 as strings identified between `*`. e.g. *001**002* -->
                <xsl:variable name="rootHLId">
                    <xsl:for-each select="ns0:HLLoop1">
                        <xsl:choose>
                            <xsl:when test="ns0:HL/HL03='S'">
                                *<xsl:value-of select="ns0:HL/HL01"/>*
                            </xsl:when>
                            <xsl:when test="ns0:HL/HL03='O'">
                                *<xsl:value-of select="ns0:HL/HL01"/>*
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:choose>
                <xsl:when test="count(//ns0:HLLoop1/ns0:HL[HL03='T']) > 0 or count(//ns0:HLLoop1/ns0:HL[HL03='P']) > 0">
                "handlingUnits": {
                    <xsl:if test="count(//ns0:HLLoop1/ns0:HL[HL03='T']) > 0">
                    "huPallet": {
                        <xsl:variable name="palletCount" select="count(//ns0:HLLoop1/ns0:HL[contains($rootHLId, concat('*',concat(HL02,'*'))) and HL03='T'])"/>
                        "count": <xsl:value-of select="$palletCount"/>,
                        "pallet": [
                        <xsl:for-each select="ns0:HLLoop1">
                            <xsl:if test="ns0:HL[contains($rootHLId, concat('*',concat(HL02,'*'))) and HL03='T'] ">
                            {
                                <xsl:variable name="palletIdentifier" select="ns0:HL/HL01"/>
                                <xsl:variable name="cartonsCount" select="count(//ns0:HLLoop1/ns0:HL[HL02=$palletIdentifier and HL03='P'])"/>
                                "palletId": "<xsl:value-of select="ns0:MAN/MAN02"/>",
                                "palletIdQualf": "<xsl:value-of select="ns0:MAN/MAN01"/>",
                                "count": <xsl:value-of select="$cartonsCount"/>,
                                "carton": [
                                    <xsl:for-each select="//ns0:HLLoop1">
                                        <xsl:if test="ns0:HL[HL02=$palletIdentifier and HL03='P']">
                                        {
                                            <xsl:variable name="cartonIdentifier" select="ns0:HL/HL01"/>
                                            "cartonId": "<xsl:value-of select="ns0:MAN/MAN02"/>",
                                            "cartonIdQualf": "<xsl:value-of select="ns0:MAN/MAN01"/>",
                                            <xsl:for-each select="//ns0:HLLoop1">
                                                <xsl:if test="ns0:HL[HL02=$cartonIdentifier and HL03='I'] and ns0:SLN/SLN09='CH'">
                                                "coo": "<xsl:value-of select="ns0:SLN/SLN10"/>",
                                                </xsl:if>
                                            </xsl:for-each>
                                            "ref": [
                                                <xsl:for-each select="//ns0:HLLoop1">
                                                    <xsl:if test="ns0:HL[HL02=$cartonIdentifier and HL03='I']">
                                                        <xsl:if test="(ns0:SLN/SLN11 = 'PJ') and (ns0:SLN/SLN12 != '')">
                                                        {
                                                            "cartonQualf": "<xsl:value-of select="ns0:SLN/SLN11"/>",
                                                            "value": "<xsl:value-of select="ns0:SLN/SLN12"/>"
                                                        },
                                                        </xsl:if>
                                                    </xsl:if>
                                                </xsl:for-each>
                                            ],
                                            "contents": [
                                                <xsl:for-each select="//ns0:HLLoop1">
                                                    <xsl:if test="ns0:HL[HL02=$cartonIdentifier and HL03='I']">
                                                        <xsl:choose>
                                                            <xsl:when test="string-length(ns0:SLN/SLN04) != 0">
                                                                {
                                                                    "shipmentLineId": "<xsl:value-of select="ns0:LIN/LIN01"/>",
                                                                    "quantity": <xsl:value-of select="ns0:SLN/SLN04"/>
                                                                },
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                 {
                                                                    "shipmentLineId": "<xsl:value-of select="ns0:LIN/LIN01"/>",
                                                                    "quantity": <xsl:value-of select="ns0:SN1/SN102"/>
                                                                },
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:if>
                                                </xsl:for-each>
                                            ]
                                        },
                                        </xsl:if>
                                    </xsl:for-each>
                                ]
                            },
                        </xsl:if>
                        </xsl:for-each>
                        ]
                    },
                    </xsl:if>
                    <xsl:if test="count(//ns0:HLLoop1/ns0:HL[HL03='P']) > 0">
                    "huCarton": {
                        <xsl:variable name="huCartonCount" select="count(ns0:HLLoop1/ns0:HL[contains($rootHLId, concat('*',concat(HL02,'*'))) and HL03='P'] )"/>
                        <xsl:if test="$huCartonCount > 0">
                        "count": <xsl:value-of select="$huCartonCount"/>,
                        "carton": [
                        <xsl:for-each select="ns0:HLLoop1">
                            <xsl:if test="ns0:HL[contains($rootHLId, concat('*',concat(HL02,'*'))) and HL03='P']">
                            {
                                <xsl:variable name="cartonIdentifier" select="ns0:HL/HL01"/>
                                "cartonId": "<xsl:value-of select="ns0:MAN/MAN02"/>",
                                "cartonIdQualf": "<xsl:value-of select="ns0:MAN/MAN01"/>",
                                <xsl:for-each select="//ns0:HLLoop1">
                                    <xsl:if test="ns0:HL[HL02=$cartonIdentifier and HL03='I'] and ns0:SLN/SLN09='CH'">
                                    "coo": "<xsl:value-of select="ns0:SLN/SLN10"/>",
                                    </xsl:if>
                                </xsl:for-each>
                                "ref": [
                                    <xsl:for-each select="//ns0:HLLoop1">
                                        <xsl:if test="ns0:HL[HL02=$cartonIdentifier and HL03='I']">
                                            <xsl:if test="(ns0:SLN/SLN11 = 'PJ') and (ns0:SLN/SLN12 != '')">
                                            {
                                                "cartonQualf": "<xsl:value-of select="ns0:SLN/SLN11"/>",
                                                "value": "<xsl:value-of select="ns0:SLN/SLN12"/>"
                                            },
                                            </xsl:if>
                                        </xsl:if>
                                    </xsl:for-each>
                                ],
                                "contents": [
                                    <xsl:for-each select="//ns0:HLLoop1">
                                        <xsl:if test="ns0:HL[HL02=$cartonIdentifier and HL03='I']">
                                        <xsl:choose>
                                            <xsl:when test="ns0:SLN/SLN04 != ''">
                                                {
                                                "shipmentLineId": "<xsl:value-of select="ns0:LIN/LIN01"/>",
                                                "quantity": <xsl:value-of select="ns0:SLN/SLN04"/>
                                            },
                                            </xsl:when>
                                            <xsl:otherwise>
                                                {
                                                "shipmentLineId": "<xsl:value-of select="ns0:LIN/LIN01"/>",
                                                "quantity":  <xsl:value-of select="ns0:SN1/SN102"/>
                                                },
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        </xsl:if>
                                    </xsl:for-each>
                                ]
                            },
                            </xsl:if>
                        </xsl:for-each>
                        ]
                        </xsl:if>
                    }
                    </xsl:if>
                }
                 </xsl:when>
                </xsl:choose>
            }
        ]
            </xsl:when>
            <xsl:when test="ns0:BSN/BSN01 = '03'">
                <xsl:variable name="deleteReason">
                    <xsl:choose>
                        <xsl:when test="ns0:BSN/BSN07='A40'">1</xsl:when>
                        <xsl:when test="ns0:BSN/BSN07='W05'">2</xsl:when>
                        <xsl:when test="ns0:BSN/BSN07='UND'">4</xsl:when>
                        <xsl:otherwise>4</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                "method": "DELETE",
                <xsl:variable name="singleQuote">'</xsl:variable> 
                "url": "<xsl:value-of select="$input:host"/>/api/shipments/<xsl:value-of select="ns0:BSN/BSN02"/>?participants=<xsl:value-of select="translate($input:participants, $singleQuote, '')" />&amp;deleteReason=<xsl:value-of select="$deleteReason"/>",
                "payload" : ""
            </xsl:when>
        </xsl:choose>
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

    <xsl:template match="ns0:LIN">
     <xsl:if test="generate-id() = generate-id(key('lineKey', LIN01)[1])">
        {
            "line": "<xsl:value-of select="LIN01"/>",
            "ref": [
                    {
                        "idQualf": "<xsl:value-of select="'ZF'" />",
                        "id": "<xsl:value-of select="'T2'" />",
                         "desc": ""
                    },
                    <xsl:if test="../ns0:PRF != ''">
                        {
                            "idQualf": "<xsl:value-of select="'OP'" />",
                            "id": "<xsl:value-of select="../ns0:PRF/PRF01"/>",
                            "desc": ""
                        },
                    </xsl:if>
                    <xsl:for-each select="../ns0:REF">
                        <xsl:choose>
                            <xsl:when test="REF01 = '2I'">
                                {
                                    "idQualf": "<xsl:value-of select="'LTN'" />",
                                    "id": "<xsl:value-of select="REF02"/>",
                                    "desc": "<xsl:value-of select="REF03"/>"
                                },
                            </xsl:when>
                                <xsl:when test="REF01 = 'LI'">
                                    {
                                        "idQualf": "<xsl:value-of select="'CL'" />",
                                        "id": "<xsl:value-of select="REF02"/>",
                                        "desc": "<xsl:value-of select="REF03"/>"
                                    },
                                </xsl:when>
                                <xsl:when test="REF01 = 'PE'">
                                    {
                                        "idQualf": "<xsl:value-of select="'ZFP'" />",
                                        "id": "<xsl:value-of select="REF02"/>",
                                        "desc": "<xsl:value-of select="REF03"/>"
                                    },
                                </xsl:when>
                                            
                                <xsl:when test="REF01 = 'OP'">
                                    <xsl:choose>
                                        <xsl:when test="../ns0:PRF != ''">
                                        </xsl:when>
                                        <xsl:otherwise>
                                            {
                                                "idQualf": "<xsl:value-of select="'OP'" />",
                                                "id": "<xsl:value-of select="REF02"/>",
                                                "desc": "<xsl:value-of select="REF03"/>"
                                            },
                                        </xsl:otherwise>
                                    </xsl:choose>
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
            "product": [
                <xsl:if test="LIN02 = 'VP'">
                    {
                        "productQualf": "<xsl:value-of select="LIN02"/>",
                        "value": "<xsl:value-of select="LIN03"/>",
                        "productDescription": ""
                    },
                </xsl:if>
                <xsl:if test="LIN04 = 'BP'">
                    {
                        "productQualf": "<xsl:value-of select="LIN04"/>",
                        "value": "<xsl:value-of select="LIN05"/>",
                        "productDescription": ""
                    },
                </xsl:if>
                <xsl:if test="LIN06 = 'ZZ'">
                    {
                        "productQualf": "<xsl:value-of select="'ZM'" />",
                        "value": "<xsl:value-of select="LIN07"/>",
                        "productDescription": ""
                    },
                </xsl:if>
                ],
            "qty": [
                    <!-- <xsl:for-each select="../ns0:SN1"> -->
                        {
                            "type": "SHIP_QTY",
                            "value": <xsl:value-of select="sum(key('lineKey', LIN01)/../ns0:SN1/SN102)"/>,
                            "uom": "<xsl:value-of select="../ns0:SN1/SN103"/>"
                        }
                                    <!-- </xsl:for-each> -->
                ]                                
            },
        </xsl:if>    
    </xsl:template>

    <xsl:template name="dtmDate">
        <xsl:param name="dtmObj" select="@dtmObj"/>
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