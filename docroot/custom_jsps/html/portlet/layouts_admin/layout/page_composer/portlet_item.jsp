<%--
/**
 * Copyright (c) 2014-present Sebastien Le Marchand All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 3 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/portlet/layouts_admin/layout/page_composer/init.jsp" %>

<%  

Portlet portlet = (Portlet)request.getAttribute("portlets.jsp-portlet");

int columnCount = (Integer)request.getAttribute("portlets.jsp-columnCount");

Map<Portlet, String> portlet2columnId = (Map<Portlet, String>)request.getAttribute("portlets.jsp-portlet2columnId");
String columnId = portlet2columnId.get(portlet);

Map<Portlet, Integer> portlet2columnIndex = (Map<Portlet, Integer>)request.getAttribute("portlets.jsp-portlet2columnIndex");
int columnIndex = portlet2columnIndex.get(portlet);

Map<Portlet, Integer> portlet2columnPos = (Map<Portlet, Integer>)request.getAttribute("portlets.jsp-portlet2columnPos");
int columnPos = portlet2columnPos.get(portlet);

layout = (Layout)request.getAttribute("edit_pages.jsp-selLayout");

plid = layout.getPlid();

layoutTypePortlet = (LayoutTypePortlet)layout.getLayoutType();		 

Group group = layout.getGroup();

portletDisplay = themeDisplay.getPortletDisplay();

PortletDisplay originalPortletDisplay = new PortletDisplay(); 
		 
originalPortletDisplay.copyFrom(portletDisplay);	

%>

<%-- Following : code fragments adapted from render_portlets.jsp --%>

<% 

String portletId = portlet.getPortletId();
String rootPortletId = portlet.getRootPortletId();
String instanceId = portlet.getInstanceId();
		  
String portletPrimaryKey = PortletPermissionUtil.getPrimaryKey(plid, portletId);

 boolean showCloseIcon = true;
 boolean showConfigurationIcon = false;
 boolean showEditIcon = false;
 boolean showEditDefaultsIcon = false;
 boolean showEditGuestIcon = false;
 boolean showExportImportIcon = false;
 boolean showMoveIcon = true;
 boolean showPortletCssIcon = false;
 
 if ((!group.hasStagingGroup() || group.isStagingGroup()) &&
	(PortletPermissionUtil.contains(permissionChecker, group.getGroupId(), layout, portlet, ActionKeys.CONFIGURATION))) {

	showConfigurationIcon = true;

	boolean supportsConfigurationLAR = Validator.isNotNull(portlet.getConfigurationActionClass());
	boolean supportsDataLAR = !(portlet.getPortletDataHandlerInstance() instanceof DefaultConfigurationPortletDataHandler);

	if (supportsConfigurationLAR || supportsDataLAR || !group.isControlPanel()) {
		showExportImportIcon = true;
	}

	if (PropsValues.PORTLET_CSS_ENABLED) {
		showPortletCssIcon = true;
	}
}
 
 if (group.isLayoutPrototype()) {
	showExportImportIcon = false;
}

//Portlets cannot be moved if the column is not customizable

if (layoutTypePortlet.isCustomizable() && layoutTypePortlet.isColumnDisabled(columnId)) {
	showCloseIcon = false;
	showMoveIcon = false;
}

//Portlets in a layout linked to a layout prototype cannot be moved

if (layout.isLayoutPrototypeLinkActive()) {
	showCloseIcon = false;
	showConfigurationIcon = false;
	showMoveIcon = false;
	showPortletCssIcon = false;
}

portletDisplay.setColumnCount(columnCount);
portletDisplay.setColumnId(columnId);
portletDisplay.setColumnPos(columnPos);
portletDisplay.setId(portletId);
portletDisplay.setInstanceId(instanceId);
portletDisplay.setNamespace(PortalUtil.getPortletNamespace(portletId));
portletDisplay.setPortletName(portletConfig.getPortletName());
portletDisplay.setResourcePK(portletPrimaryKey);
portletDisplay.setRestoreCurrentView(portlet.isRestoreCurrentView());
portletDisplay.setRootPortletId(rootPortletId);
portletDisplay.setShowCloseIcon(showCloseIcon);
portletDisplay.setShowConfigurationIcon(showConfigurationIcon);
portletDisplay.setShowExportImportIcon(showExportImportIcon);
portletDisplay.setShowMoveIcon(showMoveIcon);
portletDisplay.setShowPortletCssIcon(showPortletCssIcon);

//URL close

String urlClose = themeDisplay.getPathMain() + "/portal/update_layout?p_auth=" + AuthTokenUtil.getToken(request) + "&p_l_id=" + plid + "&p_p_id=" + portletDisplay.getId() + "&p_v_l_s_g_id=" + themeDisplay.getSiteGroupId() + "&doAsUserId=" + HttpUtil.encodeURL(themeDisplay.getDoAsUserId()) + "&" + Constants.CMD + "=" + Constants.DELETE + "&referer=" + HttpUtil.encodeURL(themeDisplay.getPathMain() + "/portal/layout?p_l_id=" + plid + "&doAsUserId=" + themeDisplay.getDoAsUserId()) + "&refresh=1";

if (themeDisplay.isAddSessionIdToURL()) {
	urlClose = PortalUtil.getURLWithSessionId(urlClose, themeDisplay.getSessionId());
}

portletDisplay.setURLClose(urlClose);

//URL configuration

PortletURLImpl urlConfiguration = new PortletURLImpl(request, PortletKeys.PORTLET_CONFIGURATION, plid, PortletRequest.RENDER_PHASE);

urlConfiguration.setWindowState(LiferayWindowState.POP_UP);

urlConfiguration.setEscapeXml(false);

if (Validator.isNotNull(portlet.getConfigurationActionClass())) {
	urlConfiguration.setParameter("struts_action", "/portlet_configuration/edit_configuration");
}
else if (PortletPermissionUtil.contains(permissionChecker, layout, portletDisplay.getId(), ActionKeys.PERMISSIONS)) {
	urlConfiguration.setParameter("struts_action", "/portlet_configuration/edit_permissions");
}
else {
	urlConfiguration.setParameter("struts_action", "/portlet_configuration/edit_sharing");
}

urlConfiguration.setParameter("redirect", currentURL);
urlConfiguration.setParameter("returnToFullPageURL", currentURL);
urlConfiguration.setParameter("portletResource", portletDisplay.getId());
urlConfiguration.setParameter("resourcePrimKey", PortletPermissionUtil.getPrimaryKey(plid, portlet.getPortletId()));

portletDisplay.setURLConfiguration(urlConfiguration.toString() + "&" + PortalUtil.getPortletNamespace(PortletKeys.PORTLET_CONFIGURATION));

//URL export / import

PortletURLImpl urlExportImport = new PortletURLImpl(request, PortletKeys.PORTLET_CONFIGURATION, plid, PortletRequest.RENDER_PHASE);

urlExportImport.setWindowState(LiferayWindowState.POP_UP);

urlExportImport.setParameter("struts_action", "/portlet_configuration/export_import");
urlExportImport.setParameter("redirect", currentURL);
urlExportImport.setParameter("returnToFullPageURL", currentURL);
urlExportImport.setParameter("portletResource", portletDisplay.getId());

urlExportImport.setEscapeXml(false);

portletDisplay.setURLExportImport(urlExportImport.toString() + "&" + PortalUtil.getPortletNamespace(PortletKeys.PORTLET_CONFIGURATION));

//URL portlet css

String urlPortletCss = "javascript:;";

portletDisplay.setURLPortletCss(urlPortletCss.toString());

%>

<%-- End of code fragments adapted from render_portlets.jsp --%>

<%
String portletTitle = PortalUtil.getPortletTitle(portlet, application, locale);
%>

<div id="p_p_id_<%= portletId %>_" data-portlet-id="<%= portletId %>" class="portlet-boundary">
	<span id="p_<%= portletId %>"></span>
	<section class="portlet" id="<%= portletId %>">
		<header class="portlet-topper">
		<h1 class="portlet-title">
			<span class="taglib-text hide-accessible"><%= portletTitle %></span>  
			<span class="portlet-title-text"><%= portletTitle %></span> 
		</h1>
		<menu class="portlet-topper-toolbar">
			<liferay-portlet:icon-options />
		</menu>
		</header>
		<div class="portlet-content">
			<p class="portlet-infos">
				<liferay-ui:message key="portlet-id" />: <%= portlet.getPortletId() %>
				<br>
				<liferay-ui:message key="status" />: 
				<c:choose>
					<c:when test="<%= !portlet.isActive() %>">
						<liferay-ui:message key="inactive" />
					</c:when>
					<c:when test="<%= !portlet.isReady() %>">
						<liferay-ui:message arguments="portlet" key="is-not-ready" />
					</c:when>
					<c:when test="<%= portlet.isUndeployedPortlet() %>">
						<liferay-ui:message key="undeployed" />
					</c:when>
					<c:otherwise>
						<liferay-ui:message key="active" />
					</c:otherwise>
				</c:choose>
			</p>
		</div>
	</section>
</div>

<%

originalPortletDisplay.copyTo(portletDisplay);

%>

