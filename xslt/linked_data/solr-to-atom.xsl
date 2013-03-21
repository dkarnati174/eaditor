<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/2005/Atom" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common"
	exclude-result-prefixes="xs" version="2.0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	
	<!-- change eXist URL if running on a server other than localhost -->
	<xsl:variable name="exist-url" select="/exist-url"/>
	<!-- load config.xml from eXist into a variable which is later processed with exsl:node-set -->
	<xsl:variable name="config" select="document(concat($exist-url, 'eaditor/config.xml'))"/>
	<xsl:variable name="solr-url" select="concat(exsl:node-set($config)/config/solr_published, 'select/')"/>
	<!-- request URL -->
	<xsl:param name="base-url" select="substring-before(doc('input:url')/request/request-url, 'feed/')"/>
	
	<xsl:param name="q">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='q']/value"/>
	</xsl:param>
	<xsl:param name="start">
		<xsl:value-of select="doc('input:params')/request/parameters/parameter[name='start']/value"/>
	</xsl:param>
	<xsl:variable name="start_var" as="xs:integer">
		<xsl:choose>
			<xsl:when test="number($start)">
				<xsl:value-of select="$start"/>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="service">
		<xsl:value-of select="concat($solr-url, '?q=', encode-for-uri($q), '&amp;sort=timestamp%20desc&amp;start=',$start, '&amp;rows=100')"/>
	</xsl:variable>
	<xsl:param name="rows" as="xs:integer">100</xsl:param>
	
	
	
	<xsl:template match="/">
		<xsl:variable name="numFound">
			<xsl:value-of select="number(//result[@name='response']/@numFound)"/>
		</xsl:variable>
		<xsl:variable name="last" select="number(concat(substring($numFound, 1, string-length($numFound) - 2), '00'))"/>
		<xsl:variable name="next" select="$start_var + 100"/>
		
		
		<feed xmlns="http://www.w3.org/2005/Atom">
			<title><xsl:value-of select="exsl:node-set($config)/config/title"/></title>
			<link href="/"/>
			<link href="../feed/?q={$q}" rel="self"/>
			<id>Feed ID</id>
			
			<xsl:if test="not($next = $last)">
				<link rel="next" href="{$base-url}feed/?q={$q}&amp;start={$next}"/>
			</xsl:if>
			<link rel="last" href="{$base-url}feed/?q={$q}&amp;start={$last}"/>
			
			<author>
				<name><xsl:value-of select="exsl:node-set($config)/config/title"/></name>
			</author>
			
			<xsl:apply-templates select="document($service)/descendant::doc"/>
		</feed>
		
	</xsl:template>
	
	<xsl:template match="doc">
		<entry>
			<title>
				<xsl:value-of select="str[@name='unittitle_display']"/>
			</title>
			<link href="{$base-url}show/{str[@name='id']}"/>
			<link rel="alternate xml" type="text/xml" href="{$base-url}xml/{str[@name='id']}"/>
			
			<id>
				<xsl:value-of select="str[@name='id']"/>
			</id>
			<xsl:if test="arr[@name='mint_facet']/str[1]">
				<creator>
					<name>
						<xsl:value-of select="arr[@name='mint_facet']/str[1]"/>
					</name>
				</creator>
			</xsl:if>
			<updated>
				<xsl:value-of select="date[@name='timestamp']"/>
			</updated>
		</entry>
	</xsl:template>
</xsl:stylesheet>
