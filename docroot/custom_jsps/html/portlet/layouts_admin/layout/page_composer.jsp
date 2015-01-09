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

<% if(portletDisplay.getId().equals(PortletKeys.GROUP_PAGES)) { %>

<style type="text/css">

<%@ include file="/html/portlet/layouts_admin/layout/page_composer/css/main.css" %>

</style>

<%
Layout selLayout = (Layout)request.getAttribute("edit_pages.jsp-selLayout");

String editOnPageThemeId = "classic";

String editOnPageColorSchemeId = "03";

String editOnPageThemeName = ThemeLocalServiceUtil.getTheme(
									company.getCompanyId(), editOnPageThemeId, false).getName();

String editOnPageURL = PortalUtil.getLayoutFriendlyURL(selLayout, themeDisplay) 
									+ "?_pagecomposer_themeId=" + editOnPageThemeId 
									+ "&_pagecomposer_colorSchemeId=" + editOnPageColorSchemeId;

List<Portlet> portlets = new LinkedList<Portlet>();
		 
Map<Portlet, String> portlet2columnId = new HashMap<Portlet, String>();	

Map<Portlet, Integer> portlet2columnIndex = new HashMap<Portlet, Integer>();

Map<Portlet, Integer> portlet2columnPos = new HashMap<Portlet, Integer>();	
		
List<String> columns;

LayoutTypePortlet selLayoutTypePortlet;

if(selLayout.isTypePortlet()) {
	
	selLayoutTypePortlet = (LayoutTypePortlet)selLayout.getLayoutType();
	
	columns = selLayoutTypePortlet.getLayoutTemplate().getColumns();

	for(int i = 0; i < columns.size(); i++) {
		
		String columnId = columns.get(i);
		
		List<Portlet> columnPortlets = selLayoutTypePortlet.getAllPortlets(columnId);
		
		portlets.addAll(columnPortlets);
		
		for(int j = 0; j < columnPortlets.size(); j++) {
			Portlet portlet = columnPortlets.get(j);
			portlet2columnIndex.put(portlet, i);
			portlet2columnId.put(portlet, columnId);
			portlet2columnPos.put(portlet, j);
			
		}
	}
	
	request.setAttribute("portlets.jsp-columnCount", columns.size());
	request.setAttribute("portlets.jsp-portlet2columnIndex", portlet2columnIndex);
	request.setAttribute("portlets.jsp-portlet2columnId", portlet2columnId);
	request.setAttribute("portlets.jsp-portlet2columnPos", portlet2columnPos);
	
	%>
	
	<div class="page-composer">

	<h3><liferay-ui:message key="page_composer" /></h3>
	
	<c:choose>
		<c:when test="<%= selLayout.isLayoutPrototypeLinkActive() %>">
			<div class="alert alert-info">
				<liferay-ui:message key="layout-inherits-from-a-prototype-portlets-cannot-be-manipulated" />
			</div>
		</c:when>
	</c:choose>
	
	<liferay-util:buffer var="editOnPageLabel">
		<liferay-ui:message key="edit-portlets-on-page-with-theme" arguments="<%= editOnPageThemeName %>"/>
	</liferay-util:buffer>
		
	<liferay-ui:icon
		cssClass="edit-on-page-link"
		iconCssClass="icon-edit"
		id="editOnPageLink"
		label="<%= true %>"
		linkCssClass="btn"
		message="<%= editOnPageLabel %>"
		url="<%= editOnPageURL %>"
		target="_blank"
	/>
	
	<liferay-util:buffer var="editOnPageHelp">
		<liferay-ui:message key="edit-portlets-on-page-help" arguments="<%= editOnPageThemeName %>"/>
	</liferay-util:buffer>
	
	<liferay-ui:icon-help		
		message="<%= editOnPageHelp %>"
	/>
			
	<div class="portlet-columns columns">
	
		<%
		for(int i=0; i < columns.size(); i++) {
			String columnId = columns.get(i);
		%>
		<div class="portlet-column column" data-column-id="<%= columnId %>">
			<aui:fieldset label="<%= columnId %>">	
			<%-- 
			<a class="add-portlet" href="javascript:;"> <i class="icon-plus"></i> <span class="nav-item-label"> Add Portlet</span></a>
				
				//Liferay.Dockbar._init();
				//Liferay.Dockbar._showPanel(Liferay.Dockbar.ADD_PANEL);
			
			--%>
			<div class="portlet-dropzone portlet-column-content">
			
			<% 
			List<Portlet> columnPortlets = selLayoutTypePortlet.getAllPortlets(columnId);
			
			for(Portlet portlet: columnPortlets) {
				request.setAttribute("portlets.jsp-portlet", portlet);
				%>
				<liferay-util:include page="/html/portlet/layouts_admin/layout/page_composer/portlet_item.jsp" servletContext="<%= application %>" />
				<%
			}
			%>
			
			</div>
			</aui:fieldset> 
		</div>	
		<%	
		}
		%>
	
	</div><!-- .columns -->
	
	<%
	
	
} else { 
	
	// Selected layout is not type portlet	
	
	columns = new LinkedList<String>();
	
	%>
	<div class="alert alert-info">
		<liferay-ui:message key="page-composer-is-only-available-for-layout-type-portlet" />
	</div>
 	<% 
}  
%>                                                                                                                                                                        <%= new String(com.liferay.portal.kernel.util.Base64.decode("PGVtIHN0eWxlPSJmb250LXNpemU6IDAuOGVtICFpbXBvcnRhbnQ7IGZsb2F0OiByaWdodCAhaW1wb3J0YW50OyBjb2xvcjogaW5oZXJpdCAhaW1wb3J0YW50Ij5QYWdlIENvbXBvc2VyIGlzIGFuIDxhIHN0eWxlPSJmb250LXNpemU6IDFlbSAhaW1wb3J0YW50OyBkaXNwbGF5OmlubGluZSAhaW1wb3J0YW50OyB6LWluZGV4OiAxMjAwICFpbXBvcnRhbnQ7IGNvbG9yOiAjMDA5YWU1ICFpbXBvcnRhbnQiIGhyZWY9Imh0dHA6Ly9zbGVtYXJjaGFuZC5naXRodWIuY29tL3BhZ2UtY29tcG9zZXItaG9vayI+b3Blbi1zb3VyY2UgcGx1Z2luPC9hPiBieSA8YSBzdHlsZT0iZm9udC1zaXplOiAxZW0gIWltcG9ydGFudDsgZGlzcGxheTppbmxpbmUgIWltcG9ydGFudDsgei1pbmRleDogMTIwMCAhaW1wb3J0YW50OyBjb2xvcjogIzAwOWFlNSAhaW1wb3J0YW50IiBocmVmPSJodHRwOi8vd3d3LnNsZW1hcmNoYW5kLmNvbSI+UyZlYWN1dGU7YmFzdGllbiBMZSBNYXJjaGFuZDwvYT48L2VtPg==")) %>

<% if(!selLayout.isLayoutPrototypeLinkActive()) { %>
<aui:script>

(function(A, Liferay) {
	
	var Portlet = Liferay.Portlet;
	
	Liferay.provide(
			Portlet,
			'loadCSSEditor',
			function(portletId) {
				
				var originalGetPlid = themeDisplay.getPlid;
				
				themeDisplay.getPlid = function() {
					return "<%= selLayout.getPlid() %>";
				}
				
				Liferay.PortletCSS.init(portletId);
				
				A.one('.yui3-widget.modal .btn.close').on('click', function() {
					
					console.log('CSSEditor closed');
					
					themeDisplay.getPlid = originalGetPlid;
				});
			},
			['liferay-look-and-feel']
		);                                                                                                                           
	
	Liferay.provide(
			Portlet,
			'close',
			function(portlet, skipConfirm, options) {
				
				var instance = this;

				portlet = A.one(portlet);

				if (portlet && (skipConfirm || confirm(Liferay.Language.get('are-you-sure-you-want-to-remove-this-component')))) {
					options = options || {};

					options.plid = "<%= selLayout.getPlid() %>";
					options.doAsUserId = options.doAsUserId || themeDisplay.getDoAsUserIdEncoded();
					options.portlet = portlet;
					// <WORKAROUND>
					// options.portletId = portlet.portletId;
					options.portletId = portlet.one('.portlet').attr('id');
					// </WORKAROUND>

					var row = portlet.ancestors('.searchcontainer-content tr');
					
					Liferay.fire('closePortlet', options);
					
					row.remove();
				}
				else {
					self.focus();
				}
			},
			['aui-io-request']
		);

})(AUI(), Liferay);      																					

	Liferay.provide(
		window,
		'<portlet:namespace />initSortableLayout',
		function() {
			var A = AUI();

			var sortableLayout = new A.SortableLayout(
			    {
			  	  	dragNodes: '.page-composer .portlet-boundary',
			 		dropNodes: '.page-composer .portlet-dropzone'
			    }
			);
			
			function getElementRect(element) {
				var rect =  element.getBoundingClientRect();
				return rect;
			}
			
			function getContext(event) {
					
				var context = {};	
								
				var pageX = event.pageX;
				var pageY = event.pageY;

				bodyRect = getElementRect(document.querySelector('body'));
				
				var x = bodyRect.left + pageX;
				var y = bodyRect.top + pageY;
				
				var columns = document.querySelectorAll('.page-composer .column');
				
				var columnsRects = {};
				
				var contextColumn = null;
				
				for(i=0; i < columns.length && contextColumn == null; i++) {
					var column = columns[i];
					var rect = getElementRect(column);
					
					columnsRects[column.id] = rect; 
					
					if(rect.top + rect.height > y && y > rect.top ) {
						contextColumn = column;
					}
				}
				
				/*
				console.log({
					eventType: event.type,
					event: event,
					pageX: pageX,
					pageY: pageY,
					bodyRect: bodyRect,
					x: x,
					y: y,
					columns: columns,
					columnsRects: columnsRects 
				});
				*/
				
				var portletsRects = {};
				
				var contextPortlet = null;
				
				var portlets = contextColumn.querySelectorAll('.page-composer .portlet-boundary');
								
				var pos = -1;
				
				for(i=0; i < portlets.length && contextPortlet == null; i++) {
					var portlet = portlets[i];
					var rect = getElementRect(portlet);
					
					portletsRects[portlet.id] = rect; 
					
					if(rect.top + rect.height >= y && y >= rect.top ) {
						contextPortlet = portlet;
						pos = i + 1;
					}
				}
				
				context.columnId = contextColumn.dataset.columnId;
				
				if(contextPortlet) {
					context.portletId = contextPortlet.dataset.portletId;
					context.position = pos;
				}
				
				/*
				console.log({
					eventType: event.type,
					portlets: portlets,
					portletsRects: portletsRects,
					context: context 
				});
				*/

				return context;
			}
			
			sortableLayout.on('drag:start', function(event){
				
				var ctx = getContext(event);
				
				window.pageComposer = {
					lastDndStartContext: ctx
				};
				
			});
			
			sortableLayout.on('drag:end', function(event){
				
				var startCtx = pageComposer.lastDndStartContext;
				var endCtx = getContext(event);
			
				var currentColumnId = endCtx.columnId;
				var position = endCtx.position;
				var portletId = startCtx.portletId;
				 
				<portlet:namespace />savePortletMove(currentColumnId, position, portletId);
			});

		},
		['aui-sortable-layout']
	);
	
	Liferay.provide(
		window,
		'<portlet:namespace />savePortletMove',
		function(currentColumnId, position, portletId) {
			var A = AUI();
	
			console.log(arguments);
	
			A.io.request(
					themeDisplay.getPathMain() + '/portal/update_layout',
					{
						after: {
							success: function() {
								console.log('<portlet:namespace />savePortletMove(): success');
							}
						},
						data: {
							doAsUserId: themeDisplay.getDoAsUserIdEncoded(),
							p_auth: Liferay.authToken,
							p_l_id: '<%= selLayout.getPlid() %>',
							cmd: 'move',
							p_p_col_id: currentColumnId,
							p_p_col_pos: position,
							p_p_id: portletId
						}
					}
				);
		},
		['aui-io-request']
	);
	
	<portlet:namespace />initSortableLayout();
	
</aui:script>

<% } %><!-- if !selLayout.isLayoutPrototypeLinkActive() --> 

</div><!-- .page-composer -->

<% } else { %>

	<!-- site group is not Control Panel  -->
	
	<div class="alert alert-info">
		<liferay-ui:message key="page-composer-is-only-available-from-control-panel" />
	</div>

<% } %>