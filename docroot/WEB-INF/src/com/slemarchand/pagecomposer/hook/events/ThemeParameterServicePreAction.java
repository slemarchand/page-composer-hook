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
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.servlet.BrowserSnifferUtil;
import com.liferay.portal.kernel.util.ParamUtil;
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

import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ThemeParameterServicePreAction extends Action {


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
		
		String themeId = ParamUtil.getString(request, "themeId", null);
		
		if(themeId != null) {

			ThemeDisplay themeDisplay = (ThemeDisplay)request.getAttribute(
				WebKeys.THEME_DISPLAY);
	
			Layout layout = themeDisplay.getLayout();
	
			if (layout != null) {
				
				String colorSchemeId = ParamUtil.getString(request, "colorSchemeId", null);
				
				PermissionChecker permissionChecker = getPermissionChecker();
				
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
			
		request.setAttribute(WebKeys.THEME, theme);
		request.setAttribute("COLOR_SCHEME", colorScheme);

		themeDisplay.setLookAndFeel(theme, colorScheme);
	}
	
	public PermissionChecker getPermissionChecker() throws PrincipalException {
		PermissionChecker permissionChecker =
			PermissionThreadLocal.getPermissionChecker();

		if (permissionChecker == null) {
			throw new PrincipalException("PermissionChecker not initialized");
		}

		return permissionChecker;
	}

	private static Log _log = LogFactoryUtil.getLog(
		ThemeParameterServicePreAction.class);
}