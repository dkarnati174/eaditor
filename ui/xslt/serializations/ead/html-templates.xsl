<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:eaditor="https://github.com/ewg118/eaditor">
	
	<xsl:template match="ead:dsc">
		<a name="{generate-id(.)}"/>
		<h1>
			<xsl:choose>
				<xsl:when test="ead:head">
					<xsl:value-of select="ead:head"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Components List</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</h1>

		<xsl:apply-templates select="ead:p | ead:note"/>

		<ul id="dsc-list">
			<xsl:apply-templates select="ead:c"/>
		</ul>
	</xsl:template>

	<xsl:template match="ead:c">
		<li id="{@id}">
			<xsl:call-template name="component-template"/>
		</li>
	</xsl:template>

	<xsl:template name="component-template">
		
		<xsl:apply-templates select="ead:did"/>

		<xsl:apply-templates
			select="ead:bioghist | ead:scopecontent | ead:arrangement | ead:accessrestrict | ead:userestrict | ead:prefercite | ead:acqinfo | ead:altformavail | ead:accruals | ead:appraisal | ead:custodhist | ead:processinfo | ead:originalsloc | ead:phystech | ead:odd | ead:note | ead:bibliography | ead:otherfindaid | ead:relatedmaterial | ead:separatedmaterial | ead:fileplan"
			mode="did_level"/>

		<xsl:if test="ead:dao or ead:daogrp">
			<div class="row">
				<div class="col-md-12">
					<h2>Images</h2>
					<xsl:apply-templates select="ead:dao | ead:daogrp"/>
				</div>
			</div>
		</xsl:if>

		<xsl:apply-templates select="ead:index | ead:controlaccess"/>

		<xsl:if test="count(ead:c) &gt; 0">
			<ul>
				<xsl:apply-templates select="ead:c"/>
			</ul>
		</xsl:if>

		<xsl:if test="not(string($id))">
			<xsl:if test="@level='series'">
				<div class="backtotop">
					<a href="#top" target="_self">Back to Top</a>
				</div>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ead:did">
		<xsl:apply-templates select="ead:unittitle" mode="content"/>
		<xsl:if test="ead:unitid or ead:repository or ead:physdesc or ead:origination or ead:physloc or ead:langmaterial or ead:materialspec or ead:abstract or ead:note or ead:container">
			<dl class="dl-horizontal">
				<xsl:apply-templates select="ead:unitid"/>
				<xsl:apply-templates select="ead:container"/>
				<xsl:apply-templates select="ead:repository"/>
				<xsl:apply-templates select="ead:physdesc/ead:extent"/>
				<xsl:apply-templates select="ead:physdesc/ead:dimensions"/>
				<xsl:apply-templates select="ead:physdesc/ead:genreform"/>
				<xsl:apply-templates select="ead:physdesc/ead:physfacet"/>
				<xsl:apply-templates select="ead:origination"/>
				<xsl:apply-templates select="ead:physloc"/>
				<xsl:apply-templates select="ead:langmaterial"/>
				<xsl:apply-templates select="ead:materialspec"/>
				<xsl:apply-templates select="ead:abstract"/>
				<xsl:apply-templates select="ead:note"/>
			</dl>
		</xsl:if>
	</xsl:template>

	<xsl:template
		match="ead:bioghist | ead:scopecontent | ead:arrangement | ead:accessrestrict | ead:userestrict | ead:prefercite | ead:acqinfo | ead:altformavail | ead:accruals | ead:appraisal | ead:custodhist | ead:processinfo | ead:originalsloc | ead:phystech | ead:odd | ead:note | ead:bibliography | ead:otherfindaid | ead:relatedmaterial | ead:separatedmaterial | ead:fileplan"
		mode="did_level">
		<xsl:variable name="default_label">
			<xsl:choose>
				<xsl:when test="ead:head">
					<xsl:value-of select="ead:head"/>
				</xsl:when>
				<xsl:when test="@label">
					<xsl:value-of select="@label"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="eaditor:normalize_fields(local-name(), $lang)"/>
					<xsl:text>: </xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="clevel">
			<i>
				<xsl:value-of select="$default_label"/>
			</i>
			<xsl:apply-templates select="*[not(local-name() = 'head')]"/>
		</div>
	</xsl:template>

	<xsl:template match="ead:unittitle" mode="content">
		<xsl:choose>
			<xsl:when test="parent::node()/parent::node()/@level = 'subseries'">
				<h3>
					<xsl:if test="@label">
						<xsl:value-of select="@label"/>
						<xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:apply-templates/>
					<xsl:if test="parent::node()/ead:unitdate">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="parent::node()/ead:unitdate"/>
					</xsl:if>
				</h3>
			</xsl:when>
			<xsl:when test="parent::ead:did/parent::node()/@level = 'series' or parent::ead:did/parent::ead:c[parent::ead:dsc]">
				<h2>
					<xsl:if test="@label">
						<xsl:value-of select="@label"/>
						<xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:apply-templates/>
					<xsl:if test="parent::node()/ead:unitdate">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="parent::node()/ead:unitdate"/>
					</xsl:if>
				</h2>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="@label">
					<xsl:value-of select="@label"/>
					<xsl:text>: </xsl:text>
				</xsl:if>
				<xsl:apply-templates/>
				<xsl:if test="parent::node()/ead:unitdate">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="parent::node()/ead:unitdate"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- hide head for now, only use unittitle -->
	<xsl:template match="ead:head" mode="content"/>

	<xsl:template match="ead:container">
		<xsl:param name="count"/>
		<xsl:variable name="width">
			<xsl:value-of select="floor(100 div number($count))"/>
		</xsl:variable>
		<div style="float:left;width:{$width}%">
			<xsl:choose>
				<xsl:when test="@label"><xsl:value-of select="@label"/>: </xsl:when>
				<xsl:when test="@type"><xsl:value-of select="@type"/>: </xsl:when>
			</xsl:choose>
			<xsl:value-of select="."/>
		</div>
	</xsl:template>

	<xsl:template match="ead:daoloc" mode="collection-image">
		<xsl:variable name="photo_id" select="substring-before(tokenize(@xlink:href, '/')[last()], '_')"/>
		<xsl:variable name="flickr_uri" select="eaditor:get_flickr_uri($photo_id)"/>
		<a href="{$flickr_uri}" target="_blank">
			<img class="ci" src="{@xlink:href}"/>
		</a>
		<xsl:if test="string(parent::node()/ead:daodesc/ead:head)">
			<h3>
				<xsl:value-of select="parent::node()/ead:daodesc/ead:head"/>
			</h3>
		</xsl:if>
		<xsl:if test="string(parent::node()/ead:daodesc/ead:p[1])">
			<xsl:apply-templates select="parent::node()/ead:daodesc/ead:p"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="ead:daogrp">
		<xsl:apply-templates select="ead:daoloc[@xlink:label='Thumbnail']"/>
	</xsl:template>

	<xsl:template match="ead:dao | ead:daoloc">
		<xsl:if test="@xlink:href">
			<xsl:variable name="title">
				<xsl:if test="string(ead:daodesc/ead:head) or string(ead:daodesc/ead:p[1])">

					<xsl:choose>
						<xsl:when test="string(ead:daodesc/ead:p[1]) and not(string(ead:daodesc/ead:head))">
							<xsl:value-of select="ead:daodesc/ead:p[1]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="ead:daodesc/ead:head"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="not(child::daodesc) and string(parent::ead:daogrp/ead:daodesc/ead:head) or string(parent::ead:daogrp/ead:daodesc/ead:p[1])">
					<xsl:choose>
						<xsl:when test="string(parent::ead:daogrp/ead:daodesc/ead:p[1]) and not(string(parent::ead:daogrp/ead:daodesc/ead:head))">
							<xsl:value-of select="parent::ead:daogrp/ead:daodesc/ead:p[1]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="parent::ead:daogrp/ead:daodesc/ead:head"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:variable>

			<div class="thumbImage col-md-2 display-thumb">
				<xsl:choose>
					<xsl:when test="contains(@xlink:href, 'flickr.com')">
						<xsl:variable name="photo_id" select="substring-before(tokenize(@xlink:href, '/')[last()], '_')"/>
						<xsl:variable name="flickr_uri" select="eaditor:get_flickr_uri($photo_id)"/>
						<a href="#{generate-id()}" title="{if (string(@title)) then @title else $title}" rel="gallery">
							<img class="ci" src="{@xlink:href}"/>
						</a>
						<div style="display:none">
							<div id="{generate-id()}">
								<span href="{$flickr_uri}" class="flickr-link">
									<xsl:choose>
										<!-- display Medium primarily, Small secondarily -->
										<xsl:when test="string(parent::node()/ead:daoloc[@xlink:label='Medium']/@xlink:href)">
											<img src="{parent::node()/ead:daoloc[@xlink:label='Medium']/@xlink:href}"/>
										</xsl:when>
										<xsl:otherwise>
											<img src="{parent::node()/ead:daoloc[@xlink:label='Small']/@xlink:href}"/>
										</xsl:otherwise>
									</xsl:choose>

								</span>
							</div>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="href">
							<xsl:choose>
								<xsl:when test="contains(@xlink:href, 'http://')">
									<xsl:value-of select="@xlink:href"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($display_path, @xlink:href)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="medium-href">
							<xsl:choose>
								<xsl:when test="contains(parent::node()/ead:daoloc[@xlink:label='Medium']/@xlink:href, 'http://')">
									<xsl:value-of select="parent::node()/ead:daoloc[@xlink:label='Medium']/@xlink:href"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat($display_path, parent::node()/ead:daoloc[@xlink:label='Medium']/@xlink:href)"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>

						<xsl:choose>
							<xsl:when test="string($medium-href)">
								<a href="{$medium-href}" title="{if (string(@title)) then @title else $title}" rel="gallery">
									<img src="{$href}"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<img src="{$href}" title="{if (string(@title)) then @title else $title}"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="string($title)">
					<br/>
					<xsl:value-of select="if (string-length($title) &gt; 36) then concat(substring($title, 1, 36), '...') else $title"/>
				</xsl:if>

			</div>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
