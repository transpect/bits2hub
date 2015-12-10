<?xml version="1.0" encoding="utf-8"?>
<p:declare-step version="1.0"
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io" 
  type="tr:bits2hub"
  name="bits2hub">
  
  <p:documentation>BITS (Book Interchange Tag Suite) to Hub conversion.</p:documentation>
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="'debug'"/>
  <p:option name="status-dir-uri" required="false" select="'status'"/>
  
  <p:input port="source" primary="true" sequence="false">
    <p:documentation>BITS XML document.</p:documentation>
  </p:input>
  <p:input port="stylesheet">
    <p:document href="http://transpect.io/bits2hub/xsl/bits2hub.xsl"/>
    <p:documentation>For usage in JATS, HoBoTS or another custom JATS XML context: 
      import the default stylesheet http://transpect.io/bits2hub/xsl/bits2hub.xsl 
      in your project specific XSL file and overwrite templates to your needs.</p:documentation>
  </p:input>
  <p:output port="result" primary="true">
    <p:documentation>Hub XML document (version 1.2).</p:documentation>
  </p:output>
  <p:serialization port="result" encoding="UTF-8" omit-xml-declaration="false"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xml-model/xpl/prepend-hub-xml-model.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  
  <tr:simple-progress-msg name="start-msg" file="bits2hub-start.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Starting JATS/BITS/HoBoTS XML to Hub conversion</c:message>
          <c:message xml:lang="de">Beginne Konvertierung von JATS/BITS/HoBoTS XML nach Hub</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
  <tr:xslt-mode prefix="bits2hub" mode="bits2hub-default">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="bits2hub"/>
    </p:input>
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"><p:empty/></p:with-option>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"><p:empty/></p:with-option>
  </tr:xslt-mode>

  <tr:prepend-hub-xml-model>
    <p:with-option name="hub-version" select="'1.2'"/>
  </tr:prepend-hub-xml-model>

  <tr:simple-progress-msg name="success-msg" file="bits2hub-success.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Successfully finished JATS/BITS/HoBoTS XML to Hub conversion</c:message>
          <c:message xml:lang="de">Konvertierung von JATS/BITS/HoBoTS XML nach Hub erfolgreich abgeschlossen</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>

</p:declare-step>
