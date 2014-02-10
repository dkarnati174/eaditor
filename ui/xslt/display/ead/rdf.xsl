<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:xhv="http://www.w3.org/1999/xhtml/vocab#" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
	exclude-result-prefixes="ead xlink" version="2.0">
	<!-- ***************** EAD-TO-RDF ******************-->
	<xsl:template name="ead-content">
		<arch:Collection rdf:about="{$objectUri}">
			<!-- title, creator, abstract, etc. -->
			<xsl:choose>
				<!-- apply templates for immediate did if the child is a component-->
				<xsl:when test="child::ead:did">
					<xsl:apply-templates select="ead:did"/>
				</xsl:when>
				<!-- otherwise apply template only to the archdesc/did-->
				<xsl:otherwise>
					<xsl:apply-templates select="ead:archdesc/ead:did"/>
				</xsl:otherwise>
			</xsl:choose>


			<!-- controlled vocabulary -->
			<xsl:apply-templates
				select="descendant::ead:subject[@authfilenumber]|descendant::ead:genreform[@authfilenumber]|descendant::ead:geogname[@authfilenumber]|descendant::ead:corpname[@authfilenumber]|descendant::ead:persname[@authfilenumber]"
			/>
		</arch:Collection>
	</xsl:template>

	<xsl:template match="ead:did">
		<xsl:apply-templates select="ead:unittitle|ead:unitid|ead:origination|ead:abstract|ead:extent"/>
	</xsl:template>

	<xsl:template match="ead:subject|ead:genreform|ead:origination|ead:geogname|ead:persname|ead:corpname">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="local-name()='subject'">dcterms:subject</xsl:when>
				<xsl:when test="local-name()='genreform'">dcterms:format</xsl:when>
				<xsl:when test="local-name()='persname'">dcterms:subject</xsl:when>
				<xsl:when test="local-name()='geogname'">dcterms:coverage</xsl:when>
				<xsl:when test="local-name()='corpname'">dcterms:subject</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="resource">
			<xsl:choose>
				<xsl:when test="@source='geonames'">
					<xsl:value-of select="concat('http://www.geonames.org/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="@source='pleiades'">
					<xsl:value-of select="concat('http://pleiades.stoa.org/places/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="@source='lcsh' or @source='lcgft'">
					<xsl:value-of select="concat('http://id.loc.gov/authorities/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="@source='viaf'">
					<xsl:value-of select="concat('http://viaf.org/viaf/', @authfilenumber)"/>
				</xsl:when>
				<xsl:when test="@source='aat'">
					<xsl:value-of select="concat('http://vocab.getty.edu/aat/', @authfilenumber)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="string($resource)">
			<xsl:element name="{$element}">
				<xsl:attribute name="rdf:resource" select="$resource"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ead:abstract|ead:extent|ead:origination|ead:unitid|ead:unittitle">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="local-name()='origination'">dcterms:creator</xsl:when>
				<xsl:when test="local-name()='unitid'">dcterms:identifier</xsl:when>
				<xsl:when test="local-name()='unittitle'">dcterms:title</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('dcterms:', local-name())"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:element name="{$element}">
			<xsl:if test="@xml:lang">
				<xsl:attribute name="xml:lang" select="@xml:lang"/>
			</xsl:if>
			<xsl:value-of select="."/>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
