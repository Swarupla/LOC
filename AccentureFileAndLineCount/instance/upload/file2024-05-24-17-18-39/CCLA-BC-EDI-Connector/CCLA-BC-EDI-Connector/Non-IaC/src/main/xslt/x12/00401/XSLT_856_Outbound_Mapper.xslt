<?xml version="1.0" encoding="UTF-16"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" exclude-result-prefixes="msxsl var userJScript"
                version="1.0" xmlns:ns0="http://schemas.microsoft.com/BizTalk/EDI/X12/2006"
                xmlns:userJScript="http://schemas.microsoft.com/BizTalk/2003/userJScript">
    <xsl:output omit-xml-declaration="yes" method="xml" version="1.0" />
    
    <xsl:template match="formatDate" name="formatDate">
        <xsl:param name="date" select="@date"/>
        <xsl:value-of select="translate(substring-before($date, 'T') , '-','')"/>
    </xsl:template>
    
    <xsl:template match="formatTime" name="formatTime">
        <xsl:param name="date" select="@date"/>
        <xsl:value-of select="translate(substring(substring-after($date,'T') , 0,9),':','')"/>
    </xsl:template>

     <xsl:template match="/result/isUpdate" name="checkBSN01">
         <xsl:choose>
                            <xsl:when test="/isUpdate = true">
                                <BSN01>04</BSN01>
                            </xsl:when>
                            <xsl:otherwise>
                                   <BSN01>00</BSN01>
                            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <msxsl:script language="JScript" implements-prefix="userJScript">
        <![CDATA[
    var counter = 0;
    function increment(){
        counter = counter + 1;
        return counter
    }


    var occ = 0
    function OPOccurance() {
       occ = occ + 1;
       return occ
    }

    var dt = 0
    function DTOccurance() {
       dt = dt + 1;
       return dt
    }
    function today()
    {
          var d = new Date();
    return d.getUTCFullYear() + '-' + pad(d.getUTCMonth() + 1) + '-' + pad(d.getUTCDate())
           + 'T' 
           + pad(d.getUTCHours()) + ':' + pad(d.getUTCMinutes()) + ':' + pad(d.getUTCSeconds())
           + '.000Z';
    } 

    function pad(num) {
    return (num < 10) ? '0' + num : '' + num;
  }
]]>
    </msxsl:script>
    
    <xsl:template match="/result">
        <xsl:call-template name="dataset">
            <xsl:with-param name="data" select="data" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="dataset">
        <xsl:param name="data" select="@data"/>
        <xsl:for-each select="$data">
        <xsl:choose>
            <xsl:when test="isDelete = 'true'">
                <ns0:X12_00401_856>
                    <ST>
                        <ST01>856</ST01>
                        <ST02>00001</ST02>
                    </ST>
                    <ns0:BSN>
                        <BSN01>03</BSN01>
                        <BSN02>
                            <xsl:value-of select="shipmentNumber" />
                        </BSN02> 
                        <BSN03>
                            <xsl:call-template name="formatDate">
                                <xsl:with-param name="date" select="userJScript:today()" />
                            </xsl:call-template>
                        </BSN03>
                        <BSN04>
                            <xsl:call-template name="formatTime">
                                <xsl:with-param name="date" select="userJScript:today()" />
                            </xsl:call-template>
                        </BSN04>
                        <BSN05>0001</BSN05>
                    </ns0:BSN>
                    <ns0:HLLoop1>
                        <ns0:HL>
                            <HL01>
                                <xsl:value-of select="001" />
                            </HL01>
                            <HL03>
                                <xsl:value-of select="shipmentType" />
                            </HL03>
                            <HL04>0</HL04>
                        </ns0:HL>
                    </ns0:HLLoop1>
                </ns0:X12_00401_856>
            </xsl:when>
            <xsl:otherwise>
                <ns0:X12_00401_856>
                    <ST>
                        <ST01>856</ST01>
                        <ST02>00001</ST02>
                    </ST>
                    <ns0:BSN>
                        <!-- TODO: Update this logic for 04 (Update) in XSLT & in Logic app as well-->
                        <xsl:call-template name="checkBSN01">
                            </xsl:call-template>
                        <BSN02>
                            <xsl:value-of select="shipmentNumber" />
                        </BSN02>
                        <!-- need to add function Validations.fetchDate() -->
                        <xsl:choose>
                            <xsl:when test="dtm">
                                <xsl:for-each select="dtm">
                    
                                <xsl:if test="(dateQualf = '011')">
                                    
                                    <BSN03>
                                        <xsl:call-template name="formatDate">
                                            <xsl:with-param name="date" select="date" />
                                        </xsl:call-template>
                                    </BSN03>
                                </xsl:if>
                            </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- <BSN03><xsl:value-of select="format-date(current-date(), '[Y0001][M01][D01]')" /></BSN03>    -->
                                <BSN03></BSN03>   
                            </xsl:otherwise>
                        </xsl:choose>
                         <!-- TODO : Default time to 0000 -->
                        <BSN04>0000</BSN04>
                        <BSN05>0001</BSN05> 
                    </ns0:BSN>
                    
                    <xsl:for-each select="dtm">
                        <ns0:DTM>
                            <DTM01>
                                <xsl:value-of select="dateQualf" />
                            </DTM01>
                            <DTM02>
                                <xsl:call-template name="formatDate">
                                    <xsl:with-param name="date" select="date" />
                                </xsl:call-template>
                            </DTM02>
                            <DTM03>
                                <xsl:variable name="time" select="date" />
                                <xsl:call-template name="formatTime">
                                    <xsl:with-param name="date" select="$time" />
                                </xsl:call-template></DTM03>
                                <DTM04>UT</DTM04>
                        </ns0:DTM>                            
                    </xsl:for-each>
                    
                    <xsl:variable name="shipId" select="userJScript:increment()"/> 
                    
                    <ns0:HLLoop1>
                        <ns0:HL>
                            <HL01>
                                <xsl:value-of select="$shipId" />
                            </HL01>
                            <HL03>S</HL03>
                            <HL04>1</HL04>
                        </ns0:HL>
                        
                        <xsl:for-each select="shipmentDetails">
                            <ns0:TD5>
                                <TD504>
                                    <xsl:value-of select="mode" />
                                </TD504>
                                <TD512>
                                    <xsl:choose>
                                        <xsl:when test="serviceLevel = 'S'">
                                            <xsl:value-of select="'G2'" />
                                        </xsl:when>
                                        <xsl:when test="serviceLevel = 'E'">
                                            <xsl:value-of select="'ES'" />
                                        </xsl:when>
                                    </xsl:choose>
                                </TD512>    
                            </ns0:TD5>
                        </xsl:for-each>
                        
                        <xsl:for-each select="ref">
                            <xsl:choose>
                                <xsl:when test="idQualf = 'LTN'">
                                    <ns0:REF>
                                        
                                        <REF01>
                                            <xsl:value-of select="'2I'" />
                                        </REF01>
                                        <REF02>
                                            <xsl:value-of select="id" />
                                        </REF02>
                                        <REF03>
                                            <xsl:value-of select="desc" />
                                        </REF03>
                                    </ns0:REF>
                                    
                                </xsl:when>
                                <xsl:when test="idQualf = 'CL'">
                                    <ns0:REF>
                                        
                                        <REF01>
                                            <xsl:value-of select="'LI'" />
                                        </REF01>
                                        <REF02>
                                            <xsl:value-of select="id" />
                                        </REF02>
                                        <REF03>
                                            <xsl:value-of select="desc" />
                                        </REF03>
                                    </ns0:REF>
                                    
                                </xsl:when>
                                <xsl:when test="idQualf = 'ZFP'">
                                    <ns0:REF>
                                        
                                        <REF01>
                                            <xsl:value-of select="'PE'" />
                                        </REF01>
                                        <REF02>
                                            <xsl:value-of select="id" />
                                        </REF02>
                                        <REF03>
                                            <xsl:value-of select="desc" />
                                        </REF03>
                                    </ns0:REF>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="idQualf != 'ZF'">
                                        <ns0:REF>
                                            
                                            <REF01>
                                                <xsl:value-of select="idQualf" />
                                            </REF01>
                                            <REF02>
                                                <xsl:value-of select="id" />
                                            </REF02>
                                            <REF03>
                                                <xsl:value-of select="desc" />
                                            </REF03>
                                        </ns0:REF>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>                            
                        
                        <xsl:for-each select="parties">
                            <xsl:variable name="i" select="position()" />
                            <xsl:if test="(partnQualf != 'Z2' and partnQualf != 'Z1') ">
                                <ns0:N1Loop1>
                                    <ns0:N1>
                                        <N101>
                                            <xsl:value-of select="partnQualf" />
                                        </N101>
                                        <N102>
                                            <xsl:value-of select="name1" />
                                        </N102>
                                        <!--TODO: If N104 is present then hardcode N103 to ZZ--> 
                                        <xsl:if test="partnerId != '' or partnerId != null">
                                        <N103>
                                            <xsl:value-of select="'ZZ'" />
                                        </N103>
                                        </xsl:if>                       
                                        <N104>
                                            <xsl:value-of select="partnerId" />
                                        </N104>
                                    </ns0:N1>
                                    <xsl:if test="name1 !='' or name2">
                                    <ns0:N2>
                                        <N201>
                                            <xsl:value-of select="name1" />
                                        </N201>
                                        <N202>
                                            <xsl:value-of select="name2" />
                                        </N202>
                                    </ns0:N2>
                                    </xsl:if>
                                    <xsl:if test="address/address1 !='' or address/address2">
                                        <ns0:N3>
                                        <N301>
                                            <xsl:value-of select="address/address1" />
                                        </N301>
                                        <N302>
                                            <xsl:value-of select="address/address2" />
                                        </N302>
                                    </ns0:N3>
                                    </xsl:if>
                                    <xsl:if test="address/city !='' or address/state !='' or address/zip !='' or address/country">
                                        <ns0:N4>
                                        <N401>
                                            <xsl:value-of select="address/city" />
                                        </N401>
                                        <N402>
                                            <xsl:if test="string-length(address/state) = 2">
                                                <xsl:value-of select="address/state" />
                                            </xsl:if>
                                        </N402>
                                        <N403>
                                            <xsl:value-of select="address/zip" />
                                        </N403>
                                        <N404>
                                            <xsl:value-of select="address/country" />
                                        </N404>
                                    </ns0:N4>
                                    </xsl:if>
                                    
                                    <xsl:if test="nodeId != null or nodeId != ''">
                                    <ns0:REF_3>
                                        <REF01>1W</REF01>
                                        <REF02><xsl:value-of select="nodeId"/></REF02>
                                    </ns0:REF_3>
                                    </xsl:if>
                                </ns0:N1Loop1>
                            </xsl:if>
                        </xsl:for-each>
                        
                    </ns0:HLLoop1>
                    <xsl:call-template name="orders">
                        <xsl:with-param name="shipId" select="$shipId" />
                    </xsl:call-template>
                </ns0:X12_00401_856>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Order Traversing -->
    <xsl:template match="/result/data/ref" name="orders">
        <xsl:param name="shipId" select="@shipId"/>
        <xsl:choose>
            <xsl:when test="ref">
                 <xsl:for-each select="ref">
                    <!-- <xsl:variable name="i" select="position()" /> -->
                    <xsl:variable name="refName" select="idQualf" />
                    <xsl:if test="(idQualf = 'OP') ">   
                        <xsl:variable name="orderID" select="userJScript:increment()" />
                        <!-- Increment done STPI flow -->
                        <xsl:variable name="checkIfExists" select="userJScript:OPOccurance()" />
                        <ns0:HLLoop1>
                            <ns0:HL>
                                <HL01>
                                    <xsl:value-of select="$orderID" />
                                </HL01> <!-- Unique Order Id -->
                                <HL02> <xsl:value-of select="$shipId" /></HL02> <!-- Shipment Id -->
                                <HL03>O</HL03>
                                <HL04>1</HL04>
                            </ns0:HL>
                            <ns0:PRF>
                                <PRF01>
                                    <xsl:value-of select="id" />
                                </PRF01>                        
                            </ns0:PRF>
                            <ns0:REF>
                                <REF01>
                                <xsl:value-of select="idQualf" />
                                </REF01>
                                <REF02>
                                <xsl:value-of select="id" />
                                </REF02>
                            </ns0:REF>
                        </ns0:HLLoop1>
                        <xsl:choose>
                            <xsl:when test="/result/data/handlingUnits">
                                <xsl:call-template name="pallets">
                                    <xsl:with-param name="palletParentId" select="$orderID" />
                                </xsl:call-template>
                                <xsl:call-template name="huCarton">
                                    <xsl:with-param name="orderID" select="$orderID" />
                                </xsl:call-template>
                                <xsl:call-template name="unmappedLineItems">
                                    <xsl:with-param name="orderID" select="$orderID" />
                                    <xsl:with-param name="coo" select="/result/data/coo" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="lineItemsWithoutHandlingUnits">
                                    <xsl:with-param name="shipId" select="$shipId" />
                                    <xsl:with-param name="coo" select="/result/data/coo" />
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:if>
                    <xsl:if test="position() = last()"> 
                        <xsl:variable name="checkIfExists" select="userJScript:OPOccurance()" />
                        <xsl:if test="$checkIfExists = 1 or $checkIfExists = '1'"> 
                        <xsl:choose>
                            <xsl:when test="/result/data/handlingUnits">
                                <xsl:call-template name="pallets">
                                    <xsl:with-param name="palletParentId" select="$shipId" />
                                </xsl:call-template>
                                <xsl:call-template name="huCarton">
                                    <xsl:with-param name="orderID" select="$shipId" />
                                </xsl:call-template>
                                <xsl:call-template name="unmappedLineItems">
                                    <xsl:with-param name="orderID" select="$shipId" />
                                    <xsl:with-param name="coo" select="/result/data/coo" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="lineItemsWithoutHandlingUnits">
                                    <xsl:with-param name="shipId" select="$shipId" />
                                    <xsl:with-param name="coo" select="/result/data/coo" />
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                    <xsl:choose>
                            <xsl:when test="/result/data/handlingUnits">
                                <xsl:call-template name="pallets">
                                    <xsl:with-param name="palletParentId" select="$shipId" />
                                </xsl:call-template>
                                <xsl:call-template name="huCarton">
                                    <xsl:with-param name="orderID" select="$shipId" />
                                </xsl:call-template>
                                <xsl:call-template name="unmappedLineItems">
                                    <xsl:with-param name="orderID" select="$shipId" />
                                    <xsl:with-param name="coo" select="/result/data/coo" />
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="lineItemsWithoutHandlingUnits">
                                    <xsl:with-param name="shipId" select="$shipId" />
                                    <xsl:with-param name="coo" select="/result/data/coo" />
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
       
    </xsl:template>
    
    <!-- Pallet Traversing -->
    <xsl:template match="/result/data/handlingUnits/huPallet/pallet" name="pallets">
    <!--TODO: Order ID to change Pallet Parent Id -->
        <xsl:param name="palletParentId" select="@orderID" />
        <xsl:for-each select="/result/data/handlingUnits/huPallet/pallet">
            <xsl:variable name="palletID" select="userJScript:increment()" />
            <ns0:HLLoop1>
                <ns0:HL>
                    <!-- HL01 and HL02 needs to be changed -->
                    <HL01>
                        <xsl:value-of select="$palletID" />
                    </HL01> <!-- Pallet ID -->
                    <HL02>
                        <xsl:value-of select="$palletParentId" />
                    </HL02> <!-- Order iD -->
                    <HL03>T</HL03>
                </ns0:HL>
                <ns0:MAN>
                    <MAN01>
                        <xsl:value-of select="palletIdQualf" />
                    </MAN01>
                    <MAN02>
                        <xsl:value-of select="palletId" />
                    </MAN02>
                </ns0:MAN>
            </ns0:HLLoop1>
            
            <xsl:call-template name="palletCarton">
                <xsl:with-param name="palletID" select="$palletID" />
                <xsl:with-param name="orderID" select="$palletParentId" />
            </xsl:call-template>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template match="/result/data/handlingUnits/huPallet/pallet" name="palletCarton">
        <xsl:param name="palletID" select="@palletID" />
        <xsl:param name="orderID" select="@orderID" />
        
        <xsl:for-each select="carton">
            <xsl:variable name="cartonID" select="userJScript:increment()" />
            <xsl:variable name="cartonCOO" select="coo" />
            <ns0:HLLoop1>
                <ns0:HL>
                    <HL01>
                        <xsl:value-of select="$cartonID" />
                    </HL01> <!-- Carton ID-->
                    <HL02>
                        <xsl:value-of select="$palletID" />
                    </HL02> <!-- Pallet ID-->
                    <HL03>P</HL03>
                </ns0:HL>
                <ns0:MAN>
                    <MAN01>
                        <xsl:value-of select="cartonIdQualf" />
                    </MAN01>
                    <MAN02>
                        <xsl:value-of select="cartonId" />
                    </MAN02>
                </ns0:MAN>
            </ns0:HLLoop1>
            <xsl:variable name="cartonQualf" select="ref/cartonQualf" />
            <xsl:variable name="cartonQualfId" select="ref/value" />
            <xsl:for-each select="contents">
                <xsl:call-template name="lineItems">
                    <xsl:with-param name="shiplineId" select="shipmentLineId" />
                    <xsl:with-param name="cartonId" select="$cartonID" />
                    <xsl:with-param name="cartonQualf" select="$cartonQualf" />
                    <xsl:with-param name="cartonQualfId" select="$cartonQualfId" />
                    <xsl:with-param name="coo" select="$cartonCOO" />
                </xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="/result/data/handlingUnits/huCarton/carton" name="huCarton">
        <xsl:param name="orderID" select="@orderID" />
        <xsl:for-each select="/result/data/handlingUnits/huCarton/carton">
            <xsl:variable name="huCartonID" select="userJScript:increment()" />
            <xsl:variable name="cartonCOO" select="coo" />
            <ns0:HLLoop1>
                <ns0:HL>
                    <!-- HL01 and HL02 needs to be changed -->
                    <HL01>
                        <xsl:value-of select="$huCartonID" />
                    </HL01> <!-- Pallet ID -->
                    <HL02>
                        <xsl:value-of select="$orderID" />
                    </HL02> <!-- Order iD -->
                    <HL03>P</HL03>
                </ns0:HL>
                <ns0:MAN>
                    <MAN01>
                        <xsl:value-of select="cartonIdQualf" />
                    </MAN01>
                    <MAN02>
                        <xsl:value-of select="cartonId" />
                    </MAN02>
                </ns0:MAN>
            </ns0:HLLoop1>
            <xsl:variable name="cartonQualf" select="ref/cartonQualf" />
            <xsl:variable name="cartonQualfId" select="ref/value" />
            <xsl:for-each select="contents">
                <xsl:call-template name="lineItems">
                    <xsl:with-param name="shiplineId" select="shipmentLineId" />
                    <xsl:with-param name="cartonId" select="$huCartonID" />
                    <xsl:with-param name="cartonQualf" select="$cartonQualf" />
                    <xsl:with-param name="cartonQualfId" select="$cartonQualfId" />
                    <xsl:with-param name="coo" select="$cartonCOO" />
                </xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- Line Items -->
    <xsl:template match="/result/data/lineItems" name="lineItems">
        <xsl:param name="shiplineId" select="@shiplineId" />
        <xsl:param name="cartonId" select="@cartonId" />
        <xsl:param name="cartonQualf" select="@cartonQualf" />
        <xsl:param name="cartonQualfId" select="@cartonQualfId" />
        <xsl:param name="coo" select="@coo" />
        <xsl:for-each select="/result/data/lineItems">
            <xsl:if test="($shiplineId = line) ">
                <xsl:variable name="lineItem" select="userJScript:increment()" />
                <ns0:HLLoop1>
                    <ns0:HL>
                        <!-- HL Data logic needs to be modified-->
                        <HL01>
                            <xsl:value-of select="$lineItem" />
                        </HL01> <!-- Lineitem id -->
                        <HL02>
                            <xsl:value-of select="$cartonId" />
                        </HL02> <!-- carton Id -->
                        <HL03>I</HL03>
                        <HL04>0</HL04>
                    </ns0:HL>
                    <ns0:LIN>
                        <LIN01>
                            <xsl:value-of select="line" />
                        </LIN01>
                        <!-- <xsl:variable name="productLength" select="count(product)"/> -->
                        <!-- <xsl:variable name="i" select="2" /> -->
                        <xsl:for-each select="product">
                            <xsl:if test="productQualf = 'VP'">
                                <LIN02>
                                    <xsl:value-of select="productQualf" />
                                </LIN02>
                                <LIN03>
                                    <xsl:value-of select="value" />
                                </LIN03>
                            </xsl:if>
                            </xsl:for-each>
                        <xsl:for-each select="product">
                            <xsl:if test="productQualf = 'BP'">
                                <LIN04>
                                    <xsl:value-of select="productQualf" />
                                </LIN04>
                                <LIN05>
                                    <xsl:value-of select="value" />
                                </LIN05>
                            </xsl:if>
                            </xsl:for-each>
                        <xsl:for-each select="product">
                            <xsl:if test="productQualf = 'ZM'">
                                <LIN06>
                                    <xsl:value-of select="'ZZ'" />
                                </LIN06>
                                <LIN07>
                                    <xsl:value-of select="value" />
                                </LIN07>
                            </xsl:if>
                        </xsl:for-each>
                    </ns0:LIN>
                    <ns0:SN1>
                        <!-- Need to confirm on Shiped Line to provide SN101 -->
                        <SN101>
                            <xsl:value-of select="line" />
                        </SN101>
                        <SN102> <xsl:value-of select="qty/value" /></SN102>
                        <SN103><xsl:value-of select="qty/uom" /> </SN103>
                    </ns0:SN1>
                    
                    <ns0:SLN>
                        <!-- Need to confirm on Shiped Line to provide SLN101 -->
                        <SLN01>
                            <xsl:value-of select="line" />
                        </SLN01>
                        <!-- TODO : Need to check on Value SLN03 -->
                        <SLN03>A</SLN03>
                        <SLN04>
                            <xsl:value-of select="qty/value" />
                        </SLN04>
                        <ns0:C001>
                            <C00101><xsl:value-of select="qty/uom" /></C00101>
                        </ns0:C001>
                       
                            <xsl:choose>
                                <xsl:when test="$coo != null">
                                 <SLN09>CH</SLN09>
                                    <SLN10>
                                    <xsl:value-of select="$coo"/>
                                    </SLN10>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="coo">
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        
                        <SLN11><xsl:value-of select="$cartonQualf"/></SLN11>
                        <SLN12><xsl:value-of select="$cartonQualfId"/></SLN12>
                    </ns0:SLN>
                        <!-- Need to Verify on PRF's (PRF01 , PRF02) tags   -->
                        <xsl:for-each select="ref">
                            <xsl:if test="(idQualf = 'OP') ">
                            <ns0:PRF>

                                <PRF01>
                                    <xsl:value-of select="id" />
                                </PRF01>
                            </ns0:PRF>

                            </xsl:if>
                        </xsl:for-each>
                    <!-- TODO: Iterate on product array loop to get PID. If DESC is there, then only add this TAG -->
                    <xsl:for-each select="product">
                        <xsl:choose>
                            <xsl:when test="productDescription">
                                <ns0:PID>
                                    <PID01>F</PID01>
                                    <PID05><xsl:value-of select="productDescription"/></PID05>
                                </ns0:PID>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                    
                    <xsl:for-each select="ref">
                        <xsl:choose>
                            <xsl:when test="idQualf = 'LTN'">
                                <ns0:REF>
                                    <REF01>
                                        <xsl:value-of select="'2I'" />
                                    </REF01>
                                    <REF02>
                                        <xsl:value-of select="id" />
                                    </REF02>
                                    <REF03>
                                        <xsl:value-of select="desc" />
                                    </REF03>
                                </ns0:REF>
                                
                            </xsl:when>
                            <xsl:when test="idQualf = 'CL'">
                                <ns0:REF>
                                    
                                    <REF01>
                                        <xsl:value-of select="'LI'" />
                                    </REF01>
                                    <REF02>
                                        <xsl:value-of select="id" />
                                    </REF02>
                                    <REF03>
                                        <xsl:value-of select="desc" />
                                    </REF03>
                                </ns0:REF>
                                
                            </xsl:when>
                            <xsl:when test="idQualf = 'ZFP'">
                                <ns0:REF>
                                    
                                    <REF01>
                                        <xsl:value-of select="'PE'" />
                                    </REF01>
                                    <REF02>
                                        <xsl:value-of select="id" />
                                    </REF02>
                                    <REF03>
                                        <xsl:value-of select="desc" />
                                    </REF03>
                                </ns0:REF>
                                
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="idQualf != 'ZF'">
                                    <ns0:REF>
                                        <REF01>
                                            <xsl:value-of select="idQualf" />
                                        </REF01>
                                        <REF02>
                                            <xsl:value-of select="id" />
                                        </REF02>
                                        <REF03>
                                            <xsl:value-of select="desc" />
                                        </REF03>
                                    </ns0:REF>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </ns0:HLLoop1>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

   <xsl:template match="/result/data/lineItems" name="lineItemsWithoutHandlingUnits">
        <xsl:param name="shipId" select="@shipId" />
        <xsl:param name="coo" select="@coo" />
        <xsl:for-each select="/result/data/lineItems">
            <xsl:variable name="lineItem" select="userJScript:increment()" />
                <ns0:HLLoop1>
                    <ns0:HL>
                        <!-- HL Data logic needs to be modified-->
                        <HL01>
                            <xsl:value-of select="$lineItem" />
                        </HL01> <!-- Lineitem id -->
                        <HL02>
                            <xsl:value-of select="$shipId" />
                        </HL02> <!-- carton Id -->
                        <HL03>I</HL03>
                        <HL04>0</HL04>
                    </ns0:HL>
                    <ns0:LIN>
                        <LIN01>
                            <xsl:value-of select="line" />
                        </LIN01>
                        <!-- <xsl:variable name="productLength" select="count(product)"/> -->
                        <!-- <xsl:variable name="i" select="2" /> -->
                        <xsl:for-each select="product">
                            <xsl:if test="productQualf = 'VP'">
                                <LIN02>
                                    <xsl:value-of select="productQualf" />
                                </LIN02>
                                <LIN03>
                                    <xsl:value-of select="value" />
                                </LIN03>
                            </xsl:if>
                            </xsl:for-each>
                        <xsl:for-each select="product">
                            <xsl:if test="productQualf = 'BP'">
                                <LIN04>
                                    <xsl:value-of select="productQualf" />
                                </LIN04>
                                <LIN05>
                                    <xsl:value-of select="value" />
                                </LIN05>
                            </xsl:if>
                            </xsl:for-each>
                        <xsl:for-each select="product">
                            <xsl:if test="productQualf = 'ZM'">
                                <LIN06>
                                    <xsl:value-of select="'ZZ'" />
                                </LIN06>
                                <LIN07>
                                    <xsl:value-of select="value" />
                                </LIN07>
                            </xsl:if>
                        </xsl:for-each>
                    </ns0:LIN>
                    <ns0:SN1>
                        <!-- Need to confirm on Shiped Line to provide SN101 -->
                        <SN101>
                            <xsl:value-of select="line" />
                        </SN101>
                        <SN102> <xsl:value-of select="qty/value" /></SN102>
                        <SN103><xsl:value-of select="qty/uom" /> </SN103>
                    </ns0:SN1>
                    
                    <ns0:SLN>
                        <!-- Need to confirm on Shiped Line to provide SLN101 -->
                        <SLN01>
                            <xsl:value-of select="line" />
                        </SLN01>
                        <!-- TODO : Need to check on Value SLN03 -->
                        <SLN03>A</SLN03>
                        <SLN04>
                            <xsl:value-of select="qty/value" />
                        </SLN04>
                        <ns0:C001>
                            <C00101><xsl:value-of select="qty/uom" /></C00101>
                        </ns0:C001>
                       
                            <xsl:choose>
                                <xsl:when test="$coo != null">
                                 <SLN09>CH</SLN09>
                                    <SLN10>
                                    <xsl:value-of select="$coo"/>
                                    </SLN10>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="coo">
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        
                        <SLN11></SLN11>
                        <SLN12></SLN12>
                    </ns0:SLN>
                        <!-- Need to Verify on PRF's (PRF01 , PRF02) tags   -->
                        <xsl:for-each select="ref">
                            <xsl:if test="(idQualf = 'OP') ">
                            <ns0:PRF>

                                <PRF01>
                                    <xsl:value-of select="id" />
                                </PRF01>
                            </ns0:PRF>
                            </xsl:if>
                        </xsl:for-each>
                    <!-- TODO: Iterate on product array loop to get PID. If DESC is there, then only add this TAG -->
                    <xsl:for-each select="product">
                        <xsl:choose>
                            <xsl:when test="productDescription">
                                <ns0:PID>
                                    <PID01>F</PID01>
                                    <PID05><xsl:value-of select="productDescription"/></PID05>
                                </ns0:PID>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                    
                    <xsl:for-each select="ref">
                        <xsl:choose>
                            <xsl:when test="idQualf = 'LTN'">
                                <ns0:REF>
                                    <REF01>
                                        <xsl:value-of select="'2I'" />
                                    </REF01>
                                    <REF02>
                                        <xsl:value-of select="id" />
                                    </REF02>
                                    <REF03>
                                        <xsl:value-of select="desc" />
                                    </REF03>
                                </ns0:REF>
                                
                            </xsl:when>
                            <xsl:when test="idQualf = 'CL'">
                                <ns0:REF>
                                    
                                    <REF01>
                                        <xsl:value-of select="'LI'" />
                                    </REF01>
                                    <REF02>
                                        <xsl:value-of select="id" />
                                    </REF02>
                                    <REF03>
                                        <xsl:value-of select="desc" />
                                    </REF03>
                                </ns0:REF>
                                
                            </xsl:when>
                            <xsl:when test="idQualf = 'ZFP'">
                                <ns0:REF>
                                    
                                    <REF01>
                                        <xsl:value-of select="'PE'" />
                                    </REF01>
                                    <REF02>
                                        <xsl:value-of select="id" />
                                    </REF02>
                                    <REF03>
                                        <xsl:value-of select="desc" />
                                    </REF03>
                                </ns0:REF>
                                
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="idQualf != 'ZF'">
                                    <ns0:REF>
                                        <REF01>
                                            <xsl:value-of select="idQualf" />
                                        </REF01>
                                        <REF02>
                                            <xsl:value-of select="id" />
                                        </REF02>
                                        <REF03>
                                            <xsl:value-of select="desc" />
                                        </REF03>
                                    </ns0:REF>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </ns0:HLLoop1>
        </xsl:for-each>
    </xsl:template> 
    
<xsl:template match="/result/data" name="unmappedLineItems">
        <xsl:param name="orderID" select="@orderID" />
        <xsl:param name="coo" select="@coo" />
        <xsl:variable name="lineNumbers">
            <xsl:for-each select="/result/data/handlingUnits/huPallet/pallet">
                <xsl:for-each select="carton">
                    <xsl:for-each select="contents">
                        *<xsl:value-of select="shipmentLineId"/>*
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
             <xsl:for-each select="/result/data/handlingUnits/huCarton/carton">
                    <xsl:for-each select="contents">
                        *<xsl:value-of select="shipmentLineId"/>*
                    </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>

        <xsl:for-each select="/result/data/lineItems">
            <xsl:if test="contains($lineNumbers, concat('*',concat(line,'*'))) = false">
                <xsl:variable name="lineItem" select="userJScript:increment()" />
                <ns0:HLLoop1>
                    <ns0:HL>
                        <!-- HL Data logic needs to be modified-->
                        <HL01>
                            <xsl:value-of select="$lineItem" />
                        </HL01> <!-- Lineitem id -->
                        <HL02>
                            <xsl:value-of select="$orderID" />
                        </HL02> <!-- carton Id -->
                        <HL03>I</HL03>
                        <HL04>0</HL04>
                    </ns0:HL>
                    <ns0:LIN>
                        <LIN01>
                            <xsl:value-of select="line" />
                        </LIN01>
                        <!-- <xsl:variable name="productLength" select="count(product)"/> -->
                        <!-- <xsl:variable name="i" select="2" /> -->
                        <xsl:for-each select="product">
                            <xsl:if test="productQualf = 'VP'">
                                <LIN02>
                                    <xsl:value-of select="productQualf" />
                                </LIN02>
                                <LIN03>
                                    <xsl:value-of select="value" />
                                </LIN03>
                            </xsl:if>
                            </xsl:for-each>
                        <xsl:for-each select="product">
                            <xsl:if test="productQualf = 'BP'">
                                <LIN04>
                                    <xsl:value-of select="productQualf" />
                                </LIN04>
                                <LIN05>
                                    <xsl:value-of select="value" />
                                </LIN05>
                            </xsl:if>
                            </xsl:for-each>
                        <xsl:for-each select="product">
                            <xsl:if test="productQualf = 'ZM'">
                                <LIN06>
                                    <xsl:value-of select="'ZZ'" />
                                </LIN06>
                                <LIN07>
                                    <xsl:value-of select="value" />
                                </LIN07>
                            </xsl:if>
                        </xsl:for-each>
                    </ns0:LIN>
                    <ns0:SN1>
                        <!-- Need to confirm on Shiped Line to provide SN101 -->
                        <SN101>
                            <xsl:value-of select="line" />
                        </SN101>
                        <SN102> <xsl:value-of select="qty/value" /></SN102>
                        <SN103><xsl:value-of select="qty/uom" /> </SN103>
                    </ns0:SN1>
                    
                    <ns0:SLN>
                        <!-- Need to confirm on Shiped Line to provide SLN101 -->
                        <SLN01>
                            <xsl:value-of select="line" />
                        </SLN01>
                        <!-- TODO : Need to check on Value SLN03 -->
                        <SLN03>A</SLN03>
                        <SLN04>
                            <xsl:value-of select="qty/value" />
                        </SLN04>
                        <ns0:C001>
                            <C00101><xsl:value-of select="qty/uom" /></C00101>
                        </ns0:C001>
                       
                            <xsl:choose>
                                <xsl:when test="$coo != null">
                                 <SLN09>CH</SLN09>
                                    <SLN10>
                                    <xsl:value-of select="$coo"/>
                                    </SLN10>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="coo">
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        
                        <SLN11></SLN11>
                        <SLN12></SLN12>
                    </ns0:SLN>
                        <!-- Need to Verify on PRF's (PRF01 , PRF02) tags   -->
                        <xsl:for-each select="ref">
                            <xsl:if test="(idQualf = 'OP') ">
                    <ns0:PRF>

                                <PRF01>
                                    <xsl:value-of select="id" />
                                </PRF01>
                    </ns0:PRF>

                            </xsl:if>
                        </xsl:for-each>
                    <!-- TODO: Iterate on product array loop to get PID. If DESC is there, then only add this TAG -->
                    <xsl:for-each select="product">
                        <xsl:choose>
                            <xsl:when test="productDescription">
                                <ns0:PID>
                                    <PID01>F</PID01>
                                    <PID05><xsl:value-of select="productDescription"/></PID05>
                                </ns0:PID>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                    
                    <xsl:for-each select="ref">
                        <xsl:choose>
                            <xsl:when test="idQualf = 'LTN'">
                                <ns0:REF>
                                    <REF01>
                                        <xsl:value-of select="'2I'" />
                                    </REF01>
                                    <REF02>
                                        <xsl:value-of select="id" />
                                    </REF02>
                                    <REF03>
                                        <xsl:value-of select="desc" />
                                    </REF03>
                                </ns0:REF>
                                
                            </xsl:when>
                            <xsl:when test="idQualf = 'CL'">
                                <ns0:REF>
                                    
                                    <REF01>
                                        <xsl:value-of select="'LI'" />
                                    </REF01>
                                    <REF02>
                                        <xsl:value-of select="id" />
                                    </REF02>
                                    <REF03>
                                        <xsl:value-of select="desc" />
                                    </REF03>
                                </ns0:REF>
                                
                            </xsl:when>
                            <xsl:when test="idQualf = 'ZFP'">
                                <ns0:REF>
                                    
                                    <REF01>
                                        <xsl:value-of select="'PE'" />
                                    </REF01>
                                    <REF02>
                                        <xsl:value-of select="id" />
                                    </REF02>
                                    <REF03>
                                        <xsl:value-of select="desc" />
                                    </REF03>
                                </ns0:REF>
                                
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="idQualf != 'ZF'">
                                    <ns0:REF>
                                        <REF01>
                                            <xsl:value-of select="idQualf" />
                                        </REF01>
                                        <REF02>
                                            <xsl:value-of select="id" />
                                        </REF02>
                                        <REF03>
                                            <xsl:value-of select="desc" />
                                        </REF03>
                                    </ns0:REF>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </ns0:HLLoop1>
            </xsl:if>
        </xsl:for-each>
</xsl:template>
<xsl:template match="/result/data/coo" name="coo">
    <!--TODO: IF COO is available then populate Value -->
        <xsl:if test="/result/data/coo != '' or /result/data/coo != null">
        <SLN09>CH</SLN09>
         <SLN10><xsl:value-of select="/result/data/coo"/></SLN10>
        </xsl:if>
</xsl:template>
<xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>