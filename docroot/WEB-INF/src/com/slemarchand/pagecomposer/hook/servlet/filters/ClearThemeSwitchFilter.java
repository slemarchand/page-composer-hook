package com.slemarchand.pagecomposer.hook.servlet.filters;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.servlet.BaseFilter;
import com.slemarchand.pagecomposer.util.WebKeys;

import javax.servlet.FilterChain;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class ClearThemeSwitchFilter extends BaseFilter {

	@Override
	protected void processFilter(HttpServletRequest request,
			HttpServletResponse response, FilterChain filterChain)
			throws Exception {
		
		HttpSession session = request.getSession();

		session.removeAttribute(WebKeys.THEME_ID);
		session.removeAttribute(WebKeys.COLOR_SCHEME_ID);
	}

	@Override
	protected Log getLog() {
		return _log;
	}
	
	private static Log _log = LogFactoryUtil.getLog(
			ClearThemeSwitchFilter.class);
}
