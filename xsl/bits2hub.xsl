<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:bits2hub="http://transpect.io/bits2hub"
  xmlns:dbk="http://docbook.org/ns/docbook" 
  xmlns:hub="http://transpect.io/hub" 
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns="http://docbook.org/ns/docbook" 
  exclude-result-prefixes="css jats dbk xs">
  
  <xsl:template match="/*" mode="bits2hub-default">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="version" select="'5.1-variant le-tex_Hub-1.2'"/>
      <info>
        <xsl:apply-templates select="book-meta/@*" mode="#current"/>
        <xsl:call-template name="create-hub-keywordset"/>
        <xsl:apply-templates select="book-meta/node()" mode="#current"/>
      </info>
      <xsl:apply-templates select="node() except book-meta" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="create-hub-keywordset">
    <keywordset role="hub">
      <keyword role="source-type">BITS</keyword>
      <keyword role="source-dir-uri">
        <xsl:value-of select="replace(base-uri(), '[^/]+$', '')"/>
      </keyword>
      <keyword role="source-basename">
        <xsl:value-of select="substring-before(tokenize(base-uri(), '/')[last()], '.')"/>
      </keyword>
    </keywordset>
  </xsl:template>
  
  <xsl:template match="custom-meta-group" mode="bits2hub-default">
    <keywordset>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </keywordset>
  </xsl:template>
  
  <xsl:template match="custom-meta" mode="bits2hub-default">
    <xsl:if test="meta-name/*">
      <xsl:message select="'bits2hub warning: element custom-meta containing elements. Unimplemented. Content got lost: ', meta-name/*"/>
    </xsl:if>
    <keyword role="{meta-name}">
      <xsl:apply-templates select="@*, meta-value" mode="#current"/>
    </keyword>
  </xsl:template>
  
  <xsl:template match="meta-value" mode="bits2hub-default">
    <xsl:if test="*">
      <xsl:message select="'bits2hub warning: element meta-value containing elements. Unimplemented!'"/>
    </xsl:if>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:variable name="dbk-biblioid-class-values" as="xs:string+"
    select="('doi', 'isbn', 'isrn', 'issn', 'libraryofcongress', 'pubsnumber', 'uri')"/>
  
  <xsl:template match="book-id" mode="bits2hub-default">
    <biblioid role="book-id" class="{@book-id-type}">
      <xsl:if test="not(@book-id-type = $dbk-biblioid-class-values)">
        <xsl:attribute name="class" select="'other'"/>
        <xsl:attribute name="otherclass" select="@book-id-type"/>
      </xsl:if>
      <xsl:apply-templates select="@* except @book-id-type, node()" mode="#current"/>
    </biblioid>
  </xsl:template>
  
  <xsl:template match="isbn" mode="bits2hub-default">
    <biblioid role="isbn" class="{@book-id-type}">
      <xsl:if test="not(@book-id-type = $dbk-biblioid-class-values)">
        <xsl:attribute name="class" select="'other'"/>
        <xsl:attribute name="otherclass" select="@publication-format"/>
      </xsl:if>
      <xsl:apply-templates select="@* except @publication-format, node()" mode="#current"/>
    </biblioid>
  </xsl:template>
  
  <xsl:template match="book-title" mode="bits2hub-default">
    <title>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </title>
  </xsl:template>
  
  <xsl:template match="contrib-group" mode="bits2hub-default">
    <authorgroup>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </authorgroup>
  </xsl:template>
  
  <xsl:template match="contrib[not(@contrib-type) or @contrib-type eq 'author']" mode="bits2hub-default">
    <author>
      <xsl:apply-templates select="@* except @contrib-type, node()" mode="#current"/>
      <xsl:if test="count(parent::*/*) = 2 and ../bio">
        <xsl:apply-templates select="../bio" mode="#current">
          <xsl:with-param name="render" select="true()"/>
        </xsl:apply-templates>
      </xsl:if>
    </author>
  </xsl:template>
  
  <xsl:template match="contrib[@contrib-type eq 'editor']" mode="bits2hub-default">
    <editor>
      <xsl:apply-templates select="@* except @contrib-type, node()" mode="#current"/>
    </editor>
  </xsl:template>
  
  <xsl:template match="bio[count(parent::*/*) = 2 and ../contrib]" mode="bits2hub-default">
    <xsl:param name="render" select="false()"/>
    <xsl:if test="$render">
      <personblurb>
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </personblurb>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="bio[not(count(parent::*/*) = 2 and ../contrib)]" mode="bits2hub-default">
    <personblurb>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </personblurb>
  </xsl:template>
  
  <xsl:template match="app" mode="bits2hub-default">
    <appendix>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </appendix>
  </xsl:template>
  
  <xsl:template match="sec" mode="bits2hub-default">
    <section>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </section>
  </xsl:template>
  
  <xsl:template match="*[self::sec or self::title-group][label]/title" mode="bits2hub-default">
    <title>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="parent::*/label" mode="#current">
        <xsl:with-param name="render" select="true()"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="node()" mode="#current"/>
    </title>
  </xsl:template>
  
  <xsl:template match="*[self::sec or self::title-group][title]/label" mode="bits2hub-default">
    <xsl:param name="render" select="false()"/>
    <xsl:if test="$render">
      <phrase role="hub:identifier">
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </phrase>
      <tab role="hub:separator"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="sec/@disp-level" mode="bits2hub-default">
    <xsl:attribute name="annotations" select="concat(name(), ':', .)"/>
  </xsl:template>
  
  <!-- just apply content elements -->
  <xsl:template match="  app-group
                       | body
                       | book-back
                       | book-body
                       | book-part/body
                       | book-part/back
                       | book-title-group
                       | front-matter-part
                       | permissions
                       | preface/named-book-part-body
                       | dedication/named-book-part-body
                       | table-wrap
                       | title-group
                       | verse-group" mode="bits2hub-default">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- just copy elements (without a namespace; adding the dbk namespace) -->
  <xsl:template match="  caption
                       | edition
                       | glossary
                       | index
                       | preface
                       | see
                       | subtitle
                       | tbody
                       | thead
                       | toc
                       | title
                       | dedication
                       | xref[not(node())]" mode="bits2hub-default">
    <xsl:element name="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="book-part[@book-part-type eq 'chapter']" mode="bits2hub-default">
    <chapter>
      <xsl:apply-templates select="@* except @book-part-type, node()" mode="#current"/>
    </chapter>
  </xsl:template>
  
  <xsl:template match="book-part[@book-part-type eq 'part']" mode="bits2hub-default">
    <part>
      <xsl:apply-templates select="@* except @book-part-type" mode="#current"/>
      <xsl:if test="not(book-part-meta/title-group/title)">
        <title/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </part>
  </xsl:template>
  
  <xsl:template match="book-part-meta" mode="bits2hub-default">
    <info>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </info>
  </xsl:template>
  
  <xsl:template match="front-matter" mode="bits2hub-default">
    <part role="front-matter">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </part>
  </xsl:template>
  
  <xsl:template match="front-matter-part/named-book-part-body" mode="bits2hub-default">
    <preface>
      <xsl:attribute name="role" select="parent::front-matter-part/@book-part-type"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <title/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </preface>
  </xsl:template>
  
  <xsl:template match="front-matter-part[named-book-part-body]/@book-part-type" mode="bits2hub-default"/>
  
  <xsl:template match="copyright-statement" mode="bits2hub-default">
    <legalnotice>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </legalnotice>
  </xsl:template>
  
  <xsl:template match="copyright-statement/text()" mode="bits2hub-default">
    <para>
      <xsl:value-of select="."/>
    </para>
  </xsl:template>
  
  <xsl:template match="boxed-text" mode="bits2hub-default">
    <sidebar>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </sidebar>
  </xsl:template>
  
  <xsl:template match="p" mode="bits2hub-default">
    <para>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </para>
  </xsl:template>
  
  <xsl:template match="tr" mode="bits2hub-default">
    <row>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </row>
  </xsl:template>
  
  <xsl:template match="td | th" mode="bits2hub-default">
    <entry>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </entry>
  </xsl:template>
  
  <xsl:template match="colgroup" mode="bits2hub-default">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="col" mode="bits2hub-default">
    <colspec>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </colspec>
  </xsl:template>
  
  <xsl:template match="table" mode="bits2hub-default">
    <table>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="parent::*/caption" mode="#current">
        <xsl:with-param name="render" select="true()"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="node()" mode="#current"/>
    </table>
  </xsl:template>
  
  <xsl:template match="table/@width" mode="bits2hub-default">
    <xsl:if test="not(../@css:width)">
      <xsl:attribute name="css:width" select="."/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[table]/caption" mode="bits2hub-default" priority="1">
    <xsl:param name="render" select="false()"/>
    <xsl:if test="$render">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="caption[every $n in * satisfies $n/self::title]" mode="bits2hub-default">
    <xsl:apply-templates select="title" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="caption[count(*) = count(title)]/title" mode="bits2hub-default" priority="1">
    <title>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="parent::caption/parent::*/label" mode="#current">
        <xsl:with-param name="render" select="true()"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="node()" mode="#current"/>
    </title>
  </xsl:template>
  
  <xsl:template match="caption[count(*) != count(title)]/title" mode="bits2hub-default" priority="1">
    <para role="title">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="parent::caption/parent::*/label" mode="#current">
        <xsl:with-param name="render" select="true()"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="node()" mode="#current"/>
    </para>
  </xsl:template>
  
  <xsl:template match="*[caption[title]]/label" mode="bits2hub-default">
    <xsl:param name="render" select="false()"/>
    <xsl:if test="$render">
      <phrase role="hub:identifier">
        <xsl:apply-templates select="@*, node()" mode="#current"/>
      </phrase>
      <tab role="hub:separator"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="list-item" mode="bits2hub-default">
    <listitem>
      <xsl:apply-templates select="@*, label, node() except label" mode="#current"/>
    </listitem>
  </xsl:template>
  
  <xsl:template match="list-item/label" mode="bits2hub-default">
    <xsl:attribute name="override" select="."/>
    <xsl:if test="*">
      <xsl:message select="'bits2hub warning: list-item/label containing elements. Unimplemented. Content got lost: ', *"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="list" mode="bits2hub-default">
    <xsl:element name="{if(@list-type = ('order', 'alpha-lower', 'alpha-upper', 'roman-lower', 'roman-upper')) 
                        then 'orderedlist' 
                        else 'itemizedlist'}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="list/@list-type" mode="bits2hub-default"/>
  
  <xsl:template match="def-list" mode="bits2hub-default">
    <variablelist>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </variablelist>
  </xsl:template>
  
  <xsl:template match="def-item" mode="bits2hub-default">
    <varlistentry>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </varlistentry>
  </xsl:template>
  
  <xsl:template match="term" mode="bits2hub-default">
    <term>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </term>
  </xsl:template>
  
  <xsl:template match="def" mode="bits2hub-default">
    <listitem>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </listitem>
  </xsl:template>
  
  <xsl:template match="disp-quote" mode="bits2hub-default">
    <blockquote>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </blockquote>
  </xsl:template>
  
  <xsl:template match="ref-list" mode="bits2hub-default">
    <bibliography>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </bibliography>
  </xsl:template>
  
  <xsl:template match="ref" mode="bits2hub-default">
    <biblioentry>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </biblioentry>
  </xsl:template>
  
  <xsl:template match="inline-graphic" mode="bits2hub-default">
    <inlinemediaobject>
      <xsl:apply-templates select="@* except @xlink:href, alt-text" mode="#current"/>
      <imageobject>
        <imagedata fileref="{@xlink:href}"/>
      </imageobject>
    </inlinemediaobject>
  </xsl:template>
  
  <xsl:template match="graphic" mode="bits2hub-default">
    <mediaobject>
      <xsl:apply-templates select="@* except @xlink:href, node()" mode="#current"/>
      <imageobject>
        <imagedata fileref="{@xlink:href}"/>
      </imageobject>
    </mediaobject>
  </xsl:template>
  
  
  
  <xsl:template match="mixed-citation" mode="bits2hub-default">
    <bibliomixed>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </bibliomixed>
  </xsl:template>
  
  <xsl:template match="mixed-citation/@publication-type" mode="bits2hub-default">
    <xsl:attribute name="role" select="."/>
  </xsl:template>
  
  <xsl:template match="person-group" mode="bits2hub-default">
    <person>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </person>
  </xsl:template>
  
  <xsl:template match="string-name" mode="bits2hub-default">
    <personname>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </personname>
  </xsl:template>
  
  <xsl:template match="surname" mode="bits2hub-default">
    <surname>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </surname>
  </xsl:template>
  
  <xsl:template match="given-names" mode="bits2hub-default">
    <firstname>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </firstname>
  </xsl:template>
  
  <xsl:template match="prefix" mode="bits2hub-default">
    <honorific>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </honorific>
  </xsl:template>
  
  <xsl:template match="  article-title 
                       | chapter-title 
                       | mixed-citation/source" mode="bits2hub-default">
    <citetitle>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </citetitle>
  </xsl:template>
  
  <xsl:template match="volume" mode="bits2hub-default">
    <seriesvolnums>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </seriesvolnums>
  </xsl:template>
  
  <xsl:template match="book-volume-number" mode="bits2hub-default">
    <volumenum>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </volumenum>
  </xsl:template>
  
  <xsl:template match="issue" mode="bits2hub-default">
    <issuenum>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </issuenum>
  </xsl:template>
  
  <xsl:template match="publisher[publisher-name]" mode="bits2hub-default">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[self::publisher-name or self::publisher-loc]
                        [not(preceding-sibling::*[self::publisher-name or self::publisher-loc])]" 
    mode="bits2hub-default" priority="1">
    <publisher>
      <xsl:apply-templates select="self::publisher-name union following-sibling::publisher-name, 
                                   self::publisher-loc union following-sibling::publisher-loc" mode="bits2hub-default-publisher"/>
    </publisher>
  </xsl:template>
  
  <xsl:template match="publisher-name" mode="bits2hub-default-publisher">
    <publishername>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </publishername>
  </xsl:template>
  
  <xsl:template match="publisher-loc" mode="bits2hub-default-publisher">
    <address>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </address>
  </xsl:template>
  
  <xsl:template match="*[self::publisher-name or self::publisher-loc]
                        [preceding-sibling::*[self::publisher-name or self::publisher-loc]]" mode="bits2hub-default"/>
  
  <xsl:template match="mixed-citation/*[self::year or self::month or self::day]
                                       [not(preceding-sibling::*[self::year or self::month or self::day])]" 
    mode="bits2hub-default">
    <pubdate>
      <xsl:value-of select="string-join((parent::*/year, parent::*/month, parent::*/day), '-')"/>
    </pubdate>
  </xsl:template>
  
  <xsl:template match="mixed-citation/*[self::year or self::month or self::day]
                                       [preceding-sibling::*[self::year or self::month or self::day]]" mode="bits2hub-default"/>
  
  <xsl:template match="string-date" mode="bits2hub-default">
    <date>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </date>
  </xsl:template>
  
  <xsl:template match="collab[*]" mode="bits2hub-default">
    <collab>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </collab>
  </xsl:template>
  
  <xsl:template match="collab[not(*)]" mode="bits2hub-default">
    <collab>
      <xsl:apply-templates select="@*" mode="#current"/>
      <orgname>
        <xsl:apply-templates select="node()" mode="#current"/>
      </orgname>
    </collab>
  </xsl:template>

  <xsl:variable name="cite-phrase-element-names" as="xs:string*"
    select="('fpage', 'lpage', 'role', 'trans-source', 'trans-title')"/>

  <xsl:template match="mixed-citation//*[name() = $cite-phrase-element-names]" mode="bits2hub-default" priority="-1">
    <phrase role="{name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </phrase>
  </xsl:template>
  
  <xsl:template match="comment" mode="bits2hub-default">
    <annotation>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </annotation>
  </xsl:template>
  
  <xsl:template match="comment[every $n in node() satisfies $n instance of text()]" mode="bits2hub-default" priority="1">
    <annotation>
      <xsl:apply-templates select="@*" mode="#current"/>
      <para>
        <xsl:apply-templates select="node()" mode="#current"/>
      </para>
    </annotation>
  </xsl:template>
  
  <xsl:variable name="dbk-citebiblioid-class-values" as="xs:string+"
    select="('doi', 'isbn', 'isrn', 'issn', 'libraryofcongress', 'pubsnumber', 'uri')"/>
  
  <xsl:template match="pub-id" mode="bits2hub-default">
    <citebiblioid role="pub-id" class="{@pub-id-type}">
      <xsl:if test="not(@pub-id-type = $dbk-citebiblioid-class-values)">
        <xsl:attribute name="class" select="'other'"/>
        <xsl:attribute name="otherclass" select="@pub-id-type"/>
      </xsl:if>
      <xsl:apply-templates select="@* except @pub-id-type, node()" mode="#current"/>
    </citebiblioid>
  </xsl:template>
  
  <xsl:template match="verse-line" mode="bits2hub-default">
    <p remap="verse-line">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </p>
  </xsl:template>
  
  <xsl:template match="fn" mode="bits2hub-default">
    <footnote>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </footnote>
  </xsl:template>
  
  <xsl:template match="alt-text" mode="bits2hub-default">
    <alt>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </alt>
  </xsl:template>
  
  <xsl:template match="sub" mode="bits2hub-default">
    <subscript>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </subscript>
  </xsl:template>
  
  <xsl:template match="sup" mode="bits2hub-default">
    <superscript>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </superscript>
  </xsl:template>
  
  <xsl:template match="styled-content" mode="bits2hub-default">
    <phrase>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </phrase>
  </xsl:template>
  
  <xsl:template match="styled-content/@style-type" mode="bits2hub-default">
    <xsl:attribute name="role" select="."/>
  </xsl:template>

  <xsl:template match="xref[node()]" mode="bits2hub-default">
    <link>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </link>
  </xsl:template>
  
  <xsl:template match="xref[node()]/@rid" mode="bits2hub-default">
    <xsl:attribute name="linkend" select="."/>
  </xsl:template>
  
  <xsl:template match="fig" mode="bits2hub-default">
    <figure>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(caption)">
        <title>
          <xsl:apply-templates select="label" mode="#current"/>
        </title>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </figure>
  </xsl:template>
  
  <xsl:template match="ext-link" mode="bits2hub-default">
    <link>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </link>
  </xsl:template>
  
  <xsl:template match="ext-link/@ext-link-type" mode="bits2hub-default">
    <xsl:attribute name="role" select="."/>
  </xsl:template>
  
  <xsl:template match="index-term" mode="bits2hub-default">
    <indexterm>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </indexterm>
  </xsl:template>
  
  <xsl:template match="index-term//index-term" mode="bits2hub-default">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:variable name="index-lvl-names" as="xs:string+"
    select="('primary', 'secondary', 'tertiary', 'quaternary', 
             'quinary', 'senary', 'septenary', 'octonary', 'nonary', 'denary')"/>
  
  <xsl:template match="index-term//term" mode="bits2hub-default">
    <xsl:variable name="context" as="element(term)" select="."/>
    <xsl:variable name="current-topmost-indexterm" as="element(index-term)" 
      select="ancestor::index-term[not(parent::term)][1]"/>
    <xsl:variable name="el-name" as="xs:string"
      select="if(count(ancestor-or-self::term[ancestor::*[. is $current-topmost-indexterm]]) gt count($index-lvl-names)) 
              then 'bits2hub_unknown-index-lvl' 
              else $index-lvl-names[
                     position() = count($context/ancestor-or-self::term[ancestor::*[. is $current-topmost-indexterm]])
                   ]"/>
    <xsl:element name="{$el-name}">
      <xsl:apply-templates select="@*, node() except *[name() = ('index-term', 'see', 'see-also')]" mode="#current"/>
    </xsl:element>
    <xsl:apply-templates select="index-term, see, see-also" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="see-also" mode="bits2hub-default">
    <seealso>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </seealso>
  </xsl:template>
  
  <!-- bits emphasis elements without @content-type -->
  <xsl:template match="  bold 
                      | italic 
                      | strike 
                      | underline" mode="bits2hub-default">
    <emphasis role="{local-name()}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </emphasis>
  </xsl:template>
  
  <xsl:template match="break" mode="bits2hub-default">
    <br/>
  </xsl:template>
  
  <xsl:template match="target" mode="bits2hub-default">
    <anchor>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </anchor>
  </xsl:template>
  
  <!-- just copy attributes -->
  <xsl:template match="@*[name() = ('colspan', 'rowspan')]" mode="bits2hub-default">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="  @content-type
                       | @person-group-type
                       | @ref-type" mode="bits2hub-default">
    <xsl:attribute name="role" select="."/>
  </xsl:template>
  
  <xsl:template match="@id" mode="bits2hub-default">
    <xsl:attribute name="xml:id" select="."/>
  </xsl:template>
  
  <xsl:template match="  @colspan
                       | @rowspan 
                       | @width
                       | @xlink:*
                       | @xml:base
                       | @xml:lang" mode="bits2hub-default">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="@specific-use" mode="bits2hub-default">
    <xsl:attribute name="annotations" select="."/>
  </xsl:template>
  
  <xsl:template match="@dtd-version" mode="bits2hub-default"/>
  
  <!-- catch all for elements; warn -->
  <xsl:template match="*" mode="bits2hub-default" priority="-3">
    <xsl:next-match/>
    <xsl:message select="concat('bits2hub not mapped: element ', name(), ' (parent: ', name(parent::*), ')')"/>
  </xsl:template>
  
  <!-- catch all for attributes; warn -->
  <xsl:template match="@*" mode="bits2hub-default" priority="-3">
    <xsl:next-match/>
    <xsl:message select="concat('bits2hub not mapped: attribute ', name(), '; value: ', xs:string(.))"/>
  </xsl:template>
  
  <!-- catch all -->
  <xsl:template match="@* | node()" mode="bits2hub-default" priority="-5">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>