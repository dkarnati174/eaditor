<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xhv="http://www.w3.org/1999/xhtml/vocab#" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
	exclude-result-prefixes="#all" version="2.0">
	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	
	<!-- url params -->
	<xsl:param name="uri" select="doc('input:request')/request/request-url"/>
	<xsl:variable name="path">
		<xsl:choose>
			<xsl:when test="contains($uri, 'ark:/')">
				<xsl:value-of select="substring-before(substring-after(substring-after($uri, 'ark:/'), '/'), '.rdf')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before(substring-after($uri, 'id/'), '.rdf')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="objectUri">
		<xsl:choose>
			<xsl:when test="//config/ark[@enabled='true']">
				<xsl:value-of select="concat($url, 'ark:/', //config/ark/naan, '/', $path)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($url, 'id/', $path)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates select="//mods:mods"/>
		</rdf:RDF>
	</xsl:template>
	
	<!-- ***************** MODS-TO-RDF ******************-->

	<xsl:template match="mods:mods">
		<rdf:Description rdf:about="{$objectUri}">
			<dcterms:title>
				<xsl:value-of select="mods:titleInfo/mods:title"/>
			</dcterms:title>
			<xsl:apply-templates select="mods:relatedItem"/>
			<xsl:apply-templates select="descendant::mods:name|mods:topic|mods:occupation|mods:form|mods:geographic|mods:genre" mode="topic"/>
		</rdf:Description>
	</xsl:template>

	<xsl:template match="mods:relatedItem">
		<xsl:apply-templates select="mods:originInfo/mods:dateCreated"/>
		<xsl:apply-templates select="mods:physicalDescription"/>
	</xsl:template>

	<xsl:template match="mods:dateCreated">
		<dcterms:temporal>
			<xsl:value-of select="."/>
		</dcterms:temporal>
	</xsl:template>

	<xsl:template match="mods:physicalDescription">
		<xsl:if test="mods:extent">
			<dcterms:extent>
				<xsl:value-of select="mods:extent"/>
			</dcterms:extent>
		</xsl:if>
		<xsl:if test="mods:form">
			<dcterms:format>
				<xsl:value-of select="mods:form"/>
			</dcterms:format>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*" mode="topic">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="local-name()='form'">dcterms:format</xsl:when>
				<xsl:when test="local-name()='geographic'">dcterms:coverage</xsl:when>
				<xsl:otherwise>dcterms:subject</xsl:otherwise>
			</xsl:choose>

		</xsl:variable>

		<xsl:element name="{$element}" namespace="http://purl.org/dc/terms/">
			<xsl:choose>
				<xsl:when test="string(@valueURI)">
					<xsl:attribute name="rdf:resource">
						<xsl:value-of select="@valueURI"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="if (mods:namePart) then mods:namePart else ."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>

	</xsl:template>
</xsl:stylesheet>
