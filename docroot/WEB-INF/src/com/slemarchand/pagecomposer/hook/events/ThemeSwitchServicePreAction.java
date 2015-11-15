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

package com.slemarchand.pagecomposer.hook.events;

import com.liferay.portal.kernel.events.Action;
import com.liferay.portal.kernel.events.ActionException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.language.LanguageUtil;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.servlet.BrowserSnifferUtil;
import com.liferay.portal.kernel.servlet.PortalMessages;
import com.liferay.portal.kernel.servlet.taglib.util.OutputData;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.StringBundler;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.portal.model.ColorScheme;
import com.liferay.portal.model.Layout;
import com.liferay.portal.model.Theme;
import com.liferay.portal.model.User;
import com.liferay.portal.security.auth.PrincipalException;
import com.liferay.portal.security.permission.ActionKeys;
import com.liferay.portal.security.permission.PermissionChecker;
import com.liferay.portal.security.permission.PermissionThreadLocal;
import com.liferay.portal.service.ThemeLocalServiceUtil;
import com.liferay.portal.service.permission.LayoutPermissionUtil;
import com.liferay.portal.theme.ThemeDisplay;

import java.io.File;
import java.util.Date;
import java.util.Iterator;
import java.util.Locale;

import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ThemeSwitchServicePreAction extends Action {
	
	@Override
	public void run(HttpServletRequest request, HttpServletResponse response)
		throws ActionException {

		try {
			servicePre(request, response);
		}
		catch (Exception e) {
			throw new ActionException(e);
		}
	}

	protected void servicePre(
			HttpServletRequest request, HttpServletResponse response)
		throws Exception {
		
		String themeId = (String)request.getSession().getAttribute(com.slemarchand.pagecomposer.util.WebKeys.THEME_ID);
		String colorSchemeId = (String)request.getSession().getAttribute(com.slemarchand.pagecomposer.util.WebKeys.COLOR_SCHEME_ID);
		
		if(Validator.isNull(themeId)) {
			
			themeId = ParamUtil.getString(request, "_pagecomposer_themeId");
			
			if(Validator.isNotNull(themeId)) {
				request.getSession().setAttribute(com.slemarchand.pagecomposer.util.WebKeys.THEME_ID, themeId);
			}
				
			colorSchemeId = ParamUtil.getString(request, "_pagecomposer_colorSchemeId", null);
			
			if(Validator.isNotNull(colorSchemeId)) {
				request.getSession().setAttribute(com.slemarchand.pagecomposer.util.WebKeys.COLOR_SCHEME_ID, colorSchemeId);
			}
		}
		
		if(Validator.isNotNull(themeId)) {
			
			ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(
				WebKeys.THEME_DISPLAY);
	
			Layout layout = themeDisplay.getLayout();
	
			if (layout != null) {

				PermissionChecker permissionChecker = _getPermissionChecker();
				
				boolean hasPermission = LayoutPermissionUtil.contains(
						permissionChecker,
						layout.getGroupId(),
						layout.isPrivateLayout(),
						layout.getLayoutId(),
						ActionKeys.UPDATE);
				
				if(!hasPermission) {
					
					if(_log.isWarnEnabled()) {
					
						User user = permissionChecker.getUser();
					
						_log.warn("User (userId=" + user.getUserId()  
								+ ", screenName=" + user.getScreenName() 
								+ ", emailAddress=" + user.getEmailAddress() 
								+ ") attempted to switch theme for request (themeId=" + themeId + ", colorSchemeId=" 
								+ colorSchemeId);
					}
					
				} else {
			
					switchThemeForRequest(themeId, colorSchemeId, themeDisplay);
				}
			}	
		}
	}

	private void switchThemeForRequest(String themeId, String colorSchemeId,
			ThemeDisplay themeDisplay) throws SystemException {
		
		HttpServletRequest request = themeDisplay.getRequest();
		
		boolean wapTheme = BrowserSnifferUtil.isWap(request);

		long companyId = themeDisplay.getCompanyId();
		
		Theme theme = ThemeLocalServiceUtil.getTheme(companyId, themeId, wapTheme);
		ColorScheme colorScheme = null;
		
		if(colorSchemeId != null) {
			colorScheme = ThemeLocalServiceUtil.getColorScheme(companyId, themeId, colorSchemeId, wapTheme);
		} else if(theme.hasColorSchemes()) {
			Iterator<ColorScheme> it = theme.getColorSchemes().iterator();
			do {
				colorScheme = it.next();
			} while(!colorScheme.isDefaultCs() && it.hasNext());
		}
			
		// Override current theme
		
		request.setAttribute(WebKeys.THEME, theme);
		request.setAttribute("COLOR_SCHEME", colorScheme); // Can't use constant located un portal-impl.jar
		
		themeDisplay.setLookAndFeel(theme, colorScheme);
		
		// Add warning message 
		
		Locale locale = themeDisplay.getLocale();
		
		String message = LanguageUtil.format(locale, "this-page-is-displayed-with-x-theme-just-for-your-session", theme.getName())
				+ " <a id=\"clearThemeSwitchLink\" href=\"#\">" 
				+ LanguageUtil.get(locale, "display-the-page-with-original-theme") + "</a>";
		
		PortalMessages.add(request, PortalMessages.KEY_ANIMATION, false);
		PortalMessages.add(request, PortalMessages.KEY_MESSAGE, message);
		PortalMessages.add(request, PortalMessages.KEY_TIMEOUT, -1);
		PortalMessages.add(request, PortalMessages.KEY_CSS_CLASS, "alert-warn");
		
		// Inject Javascript into page bottom
		
		String javascriptSrc = themeDisplay.getPortalURL() + _JAVASCRIPT_PATH + "?t=" + _getJavascriptTimestamp(request);
		
		StringBundler sb = new StringBundler();
		
		sb.append("<script src=\"" + javascriptSrc + "\" type=\"text/javascript\"></script>");
		
		OutputData outputData = _getOutputData(request);
		
		String outputKey = this.getClass().getName();
		
		outputData.addData(outputKey, WebKeys.PAGE_BODY_BOTTOM, sb);
	}
	
	private static long _getJavascriptTimestamp(HttpServletRequest request) {
		
		if(_javascriptTimestamp == 0) {
			
			File file = new File(request.getServletContext().getRealPath(_JAVASCRIPT_PATH));
			
			if(file.exists()) {
				_javascriptTimestamp = file.lastModified();
			} else {
				_javascriptTimestamp = new Date().getTime();
			}
		}
		
		return _javascriptTimestamp;
	}
	
	private static PermissionChecker _getPermissionChecker() throws PrincipalException {
		PermissionChecker permissionChecker =
			PermissionThreadLocal.getPermissionChecker();

		if (permissionChecker == null) {
			throw new PrincipalException("PermissionChecker not initialized");
		}
		
		return permissionChecker;
	}
	
	private static OutputData _getOutputData(ServletRequest servletRequest) {
		OutputData outputData = (OutputData)servletRequest.getAttribute(
			WebKeys.OUTPUT_DATA);

		if (outputData == null) {
			outputData = new OutputData();

			servletRequest.setAttribute(WebKeys.OUTPUT_DATA, outputData);
		}

		return outputData;
	}
	
	private static long _javascriptTimestamp = 0;
	
	private static Log _log = LogFactoryUtil.getLog(
		ThemeSwitchServicePreAction.class);
	
	private static final String _JAVASCRIPT_PATH = "/html/js/page_composer/page_body_bottom.js";
}