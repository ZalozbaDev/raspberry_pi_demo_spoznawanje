#!/bin/bash

# reverse order of ALSA and PulseAudio .jar files for use of different mixer subsystem 

LD_LIBRARY_PATH=. \
java -cp istack-commons-runtime.jar:javax.activation-api.jar:jaxb-api.jar:\
jaxb-core.jar:jaxb-runtime.jar:stax-ex.jar:ips.commons.jar:\
ips.audiotools.jar:ips.speechdb.jar:ips.speechdbtools.jar:\
ips.speechrecorder.jar:javahelp.jar:jcalendar.jar:\
org.eclipse.persistence.antlr.jar:org.eclipse.persistence.asm.jar:\
org.eclipse.persistence.core.jar:org.eclipse.persistence.jpa.jar:\
org.eclipse.persistence.jpa.jpql.jar:jakarta.json.jar:javax.json-api.jar:\
javax.json.jar:org.eclipse.persistence.moxy.jar:commons-codec.jar:\
commons-lang.jar:commons-logging.jar:httpclient.jar:httpcore.jar:httpmime.jar:\
javax.json.jar:validation-api.jar:xmlgraphics-commons.jar:batik-anim.jar:\
batik-awt-util.jar:batik-bridge.jar:batik-constants.jar:batik-css.jar:\
batik-dom.jar:batik-ext.jar:batik-gui-util.jar:batik-gvt.jar:batik-i18n.jar:\
batik-parser.jar:batik-script.jar:batik-svg-dom.jar:batik-swing.jar:\
batik-util.jar:batik-xml.jar:rhino.jar:xml-apis-ext.jar:\
xmlgraphics-commons.jar:ips.speechrecorder.plugin.ampelmaennchen.trafficlights.jar:\
ips.speechrecorder.plugin.ampelmaennchen.pedestrianlights.jar:\
ips.speechrecorder.plugin.promptpresenter.svg.batik.jar:\
ips.ajs.pulseaudio.jar:ips.ajs.alsa.jar:\
-Dipsk.util.apps.descriptor.url=https://www.phonetik.uni-muenchen.de/Bas/software/speechrecorder/speechrecorderApplicationDescriptor.xml \
ipsk.apps.speechrecorder.SpeechRecorder

