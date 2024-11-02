<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson,retrievePrizeTable,getType">
				<lxslt:script lang="javascript">
					<![CDATA[
					var debugFlag = false;
					var debugFeed = [];
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param
					function formatJson(jsonContext, translations, prizeTable, convertedPrizeValues, prizeNames)
					{
						var scenario = getScenario(jsonContext);
						var nameAndCollectList = (prizeNames.substring(1)).split(',');
						var prizeValues = (convertedPrizeValues.substring(1)).split('|');
						
						var shapeSets = (scenario.split('|')[0]).split(',');
						var playData = scenario.split('|')[1];

						var prizeNamesList = [];						
						for(var i = 0; i < nameAndCollectList.length; ++i)
						{
							var desc = nameAndCollectList[i];
							prizeNamesList.push(desc[desc.length - 1]);
						}
						
						registerDebugText("Prize Names: " + prizeNamesList);
						registerDebugText("Prize Values: " + prizeValues);
						registerDebugText("Scenario: " + scenario);
						registerDebugText("Shape Sets: " + shapeSets);
						registerDebugText("Play Data: " + playData);

                        var shapeTotals = [7,6,5,4,3,2]; 
						var instantWins = "123"; 

						// Output winning numbers table.
						var r = [];

						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
						// Headers
 						r.push('<tr>');
						r.push('<td class="tablehead" width="100%">');
						r.push(getTranslationByName("yourSymbols", translations));
						r.push('</td>');
						r.push('</tr>');

						var printLine = "";
						for (var playDataPos = 0; playDataPos < playData.length; ++playDataPos)
						{
						    if (playData[playDataPos] != "X")
							{
 								r.push('<tr>');
								r.push('<td class="tablehead" width="100%">');
								if (instantWins.indexOf(playData[playDataPos]) != -1)
								{
									r.push(getTranslationByName("instantWin", translations) + " " + playData[playDataPos]);
								}
								else
								{
									r.push(getTranslationByName(playData[playDataPos], translations));
								}
								r.push('</td>');
								r.push('</tr>');
							}
						}
 						r.push('<tr>');
						r.push('<td class="tablebody">');
						r.push(getTranslationByName("X", translations));
                        r.push('</td>');
						r.push('</tr>');

 						r.push('</table>');
 						r.push('&nbsp');

						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');

						// Headers
 						r.push('<tr>');
						r.push('<td class="tablehead" width="60%">');
						r.push(getTranslationByName("paytableRow", translations));
						r.push('</td>');
						
						r.push('<td class="tablehead" width="20%">');
						r.push(getTranslationByName("numCollected", translations));
						r.push('</td>');
						
						r.push('<td class="tablehead" width="20%">');
						r.push(getTranslationByName("prize", translations));
 						r.push('</td>');
						r.push('</tr>');

                        // shape Collections
						var rowShapeNames = '';
                        for(var shape = 0; shape < shapeSets.length; ++shape)
                        {
							rowShapeNames = '';
							for (var shapePos = 0; shapePos < shapeTotals[shape]; ++shapePos)
							{
								rowShapeNames = rowShapeNames + getTranslationByName(shapeSets[shape][shapePos], translations);
								if (shapePos < (shapeTotals[shape] -1))
								{
									rowShapeNames = rowShapeNames + ", ";
								}
							}

                            var shapeCount = 0;
							var instantWin = [false,false,false];
                            for(var pick = 0; pick < playData.length; ++pick)
                            {                                
                                if(shapeSets[shape].indexOf(playData[pick]) != -1)
                                {
						            shapeCount++;
                                }               
								else if(instantWins.indexOf(playData[pick]) != -1)
								{
									instantWin[playData[pick] -1] = true;
								}                 
                            }
 							r.push('<tr>');
						    r.push('<td class="tablebody">');
						    r.push(getTranslationByName("row", translations) + " " + (shape + 1) + " " + rowShapeNames);
                            r.push('</td>');
                            r.push('<td class="tablebody">');
                            r.push(shapeCount + "/" + shapeTotals[shape]);
                            r.push('</td>');
                            
							r.push('<td class="tablebody">');
                            if(shapeCount == shapeTotals[shape])
                            {
                                r.push(prizeValues[shape]);
                            }
							r.push('</td>');
                        	r.push('</tr>');
						}
 						r.push('</table>');
						r.push('&nbsp');

						var anyInstantWins = false;
						for(var loop = 0; loop < instantWin.length; ++loop)
						{
							if(instantWin[loop] == true)
							{
								anyInstantWins = true;
							}
						}

						if(anyInstantWins)
						{
	 						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							// Headers
 							r.push('<tr>');
							r.push('<td class="tablehead" width="60%">');
							r.push(getTranslationByName("instantWins", translations));
							r.push('</td>');

							r.push('<td class="tablehead" width="20%">');
 							r.push('</td>');

							r.push('<td class="tablehead" width="20%">');
							r.push(getTranslationByName("prize", translations));
							r.push('</td>');
 							r.push('</tr>');

	                        // instant Wins
    	                    for(var iws = 0; iws < instantWin.length; ++iws)
							{
								if(instantWin[iws] == true) 
								{
									r.push('<tr>');
							    	r.push('<td class="tablebody">');
									r.push(getTranslationByName("instantWin", translations) + ' ' + instantWins[iws]);
                            		r.push('</td>');
									r.push('<td> &nbsp </td>');
							    	r.push('<td class="tablebody">');
									if(instantWin[iws] == true) 
									{
										r.push(prizeValues[shapeSets.length + iws]);
									}
									else
									{
										r.push('&nbsp');
									}
									r.push('</td>');
									r.push('</tr>');
								}
							}
							r.push('</table>');
						}
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
 						    {
								if(debugFeed[idx] == "")
									continue;
								r.push('<tr>');
								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
								r.push('</td>');
								r.push('</tr>');
							}
							r.push('</table>');
						}

						return r.join('');
					}

					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}

					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["23", "9", "31"]
					function getWinningNumbers(scenario)
					{
						var numsData = scenario.split("|")[0];
						return numsData.split(",");
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["8", "35", "4", "13", ...] or ["E", "E", "D", "G", ...]
					function getOutcomeData(scenario, index)
					{
						var outcomeData = scenario.split("|")[1];
						var outcomePairs = outcomeData.split(",");
						var result = [];
						for(var i = 0; i < outcomePairs.length; ++i)
						{
							result.push(outcomePairs[i].split(":")[index]);
						}
						return result;
					}

					// Input: List of winning numbers and the number to check
					// Output: true is number is contained within winning numbers or false if not
					function checkMatch(winningNums, boardNum)
					{
						for(var i = 0; i < winningNums.length; ++i)
						{
							if(winningNums[i] == boardNum)
							{
								return true;
							}
						}
						
						return false;
					}

					function countPrizeCollections(prizeName, scenario)
					{
						registerDebugText("Checking for prize in scenario: " + prizeName);
						var count = 0;
						for(var char = 0; char < scenario.length; ++char)
						{
							if(prizeName == scenario[char])
							{
								count++;
							}
						}

						return count;
					}

					//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeTables, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeTableStrings = prizeTables.split("|");
						
						
						for(var i = 0; i < pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								return prizeTableStrings[i];
							}
						}
						
						return "";
					}

					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);

							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							
							index += 1;
						}
					}

					// Grab Wager Type
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function getType(jsonContext, translations)
					{
						// Parse json and retrieve wagerType string.
						var jsObj = JSON.parse(jsonContext);
						var wagerType = jsObj.wagerType;

						return getTranslationByName(wagerType, translations);
					}
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='wagerType']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="my-ext:getType($odeResponseJson, $translations)" disable-output-escaping="yes" />
						</td>
					</tr>
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<br />			
				
				<x:variable name="convertedPrizeValues">

					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>

				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>


				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
