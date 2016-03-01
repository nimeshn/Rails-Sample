# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "ready page:load", ->
	formatNumber = (n, dec) ->	
		if typeof n != typeof undefined && n != ""
			n.toFixed(dec).replace(/(\d)(?=(\d{3})+\.)/g, "$1,")
		else
			""
		
	appendStats = (statsList) ->
		htmlStats = ""
		for key, stat of statsList
			stat.avg = formatNumber(stat.avg, 4)
			stat.sbp = formatNumber(stat.sbp, 2)
			stat.ops = formatNumber(stat.ops, 4)
			htmlStats = htmlStats + "<tr><td>#{stat.year}</td>
				<td>#{stat.team_name}</td>
				<td>#{stat.team_city}</td>
				<td>#{stat.surname}</td>
				<td>#{stat.given_name}</td>
				<td>#{stat.position}</td>
				<td class='text-right'>#{stat.avg}</td>
				<td class='text-right'>#{stat.home_runs}</td>
				<td class='text-right'>#{stat.rbi}</td>
				<td class='text-right'>#{stat.runs}</td>
				<td class='text-right'>#{stat.sbp}</td>
				<td class='text-right'>#{stat.ops}</td></tr>"
				
		$("#stat_table tbody").html htmlStats
		

	$("#stat_table th").click ->
		orderDesc = $(this).attr("data-field-order-desc")
		if typeof orderDesc != typeof undefined && orderDesc != false
			if orderDesc == "true"
				orderDesc = false
			else
				orderDesc = true
		else
			orderDesc = false
		orderBy = $(this).attr("data-field-name")
		
		$("#stat_table th").each ->
			$(this).find("span").removeClass("glyphicon-triangle-bottom").removeClass("glyphicon-triangle-top")
			$(this).removeAttr("data-field-order-desc")
			return
		
		$(this).attr("data-field-order-desc", orderDesc)		
		if orderDesc
			$(this).find("span").addClass "glyphicon-triangle-bottom"
		else
			$(this).find("span").addClass "glyphicon-triangle-top"
		getStatsData($("#fetchRows").val(), orderBy, orderDesc)		
		return

	getStatsData = (rowCount, orderBy, orderDesc) ->
		$.ajax
			url: "/stats/ordered/#{rowCount}/#{orderBy}/#{orderDesc}",
			type: "GET"
			dataType: "json"
			error: (jqXHR, textStatus, errorThrown) ->
				alert textStatus + ":" + errorThrown
			success: (data, textStatus, jqXHR) ->
				appendStats data
				$("#spnRecords").text("Fetched #{rowCount} records sorted by #{orderBy}")

	$("#btnFetchRows").click ->
		if $("#stat_table th[data-field-order-desc='true']").length
			columnField = $("#stat_table th[data-field-order-desc='true']")
		else if columnField = $("#stat_table th[data-field-order-desc='false']").length
			columnField = $("#stat_table th[data-field-order-desc='false']")
		else
			columnField = null
		
		if (columnField != null)
			getStatsData $("#fetchRows").val(), columnField.attr("data-field-name"), columnField.attr("data-field-order-desc")
