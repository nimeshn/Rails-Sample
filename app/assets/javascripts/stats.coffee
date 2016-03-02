# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Lets hook up on document load event
$(document).on "ready page:load", ->

	# helper function to format float as string with decimal places
	formatNumber = (n, dec) ->	
		if typeof n != typeof undefined && n != ""
			n.toFixed(dec).replace(/(\d)(?=(\d{3})+\.)/g, "$1,")
		else
			""
	
	# function to create a HTML text for table rows
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
		

	# hook up on click events for all table headers
	$("#stat_table th").click ->
		# get clicked columns field and current sort direction
		orderDesc = $(this).attr("data-field-order-desc")
		if typeof orderDesc != typeof undefined && orderDesc != false
			if orderDesc == "true"
				orderDesc = false
			else
				orderDesc = true
		else
			orderDesc = false
		orderBy = $(this).attr("data-field-name")
		
		# clear every table header's sort attribute and remove glyph
		$("#stat_table th").each ->
			$(this).find("span").removeClass("glyphicon-triangle-bottom").removeClass("glyphicon-triangle-top")
			$(this).removeAttr("data-field-order-desc")

		getStatsData($(this), $("#fetchRows").val(), orderBy, orderDesc)		
		return

	# wrapper function to get the new sorted data and update header glyph
	getStatsData = (clickedCol, rowCount, orderBy, orderDesc) ->
		$("#pleaseWaitDialog").modal("show")
		$.ajax
			url: "/stats/index/#{rowCount}/#{orderBy}/#{orderDesc}.json",
			type: "GET"
			dataType: "json"
			error: (jqXHR, textStatus, errorThrown) ->
				$("#pleaseWaitDialog").modal("hide")
				alert textStatus + ":" + errorThrown
			success: (data, textStatus, jqXHR) ->
				$("#spnRecords").text("Fetched #{data.length} records sorted by #{orderBy}")
			
				appendStats data
				
				# set the toggled sort attribute on the clicked header
				clickedCol.attr("data-field-order-desc", orderDesc)
				if orderDesc
					clickedCol.find("span").addClass "glyphicon-triangle-bottom"
				else
					clickedCol.find("span").addClass "glyphicon-triangle-top"
				$("#pleaseWaitDialog").modal("hide")

	# handle Get Stats button click 
	$("#btnFetchRows").click ->
		if $("#stat_table th[data-field-order-desc='true']").length
			columnField = $("#stat_table th[data-field-order-desc='true']")
		else if columnField = $("#stat_table th[data-field-order-desc='false']").length
			columnField = $("#stat_table th[data-field-order-desc='false']")
		else
			columnField = null
		
		if (columnField != null)
			getStatsData columnField, $("#fetchRows").val(), columnField.attr("data-field-name"), columnField.attr("data-field-order-desc")
