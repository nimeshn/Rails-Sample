class StatsController < ApplicationController
	include StatsHelper

	# Default action for showing Player Stats
	# @order_by defaults to avg column sorted desc
	# we get 25 rows by default
	def index
		if params[:row_count] != nil
			@row_count = params[:row_count].to_i 
		else
			@row_count = 25
		end
		
		if params[:order_by] != nil
			@order_by = params[:order_by] 
		else
			@order_by = 'avg'
		end
		
		if params[:order_desc] != nil
			@order_desc = params[:order_desc] == "true" 
		else
			@order_desc = true
		end
		
		@player_stats = get_player_stats(@row_count, @order_by, @order_desc)
		
		respond_to do |format|
		  format.html # index.html.erb
		  format.xml  { render xml: @player_stats}
		  format.json { render json: @player_stats}
		  format.js
		end
	end
end
