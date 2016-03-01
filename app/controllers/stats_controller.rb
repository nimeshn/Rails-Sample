class StatsController < ApplicationController
	include StatsHelper

	# Default action for showing Player Stats
	# @order_by defaults to avg column sorted desc
	# we get 25 rows by default
	def index
		@order_by = 'avg'
		@order_desc = true
		@row_count = 25
		@player_stats = get_player_stats(@row_count, @order_by, @order_desc)
	end

	# this action is used by AJAX call to get data when sorting headers
	def ordered_data
		@row_count = params[:row_count].to_i
		@order_by = params[:order_by]
		@order_desc = params[:order_desc] == "true"
		@player_stats = get_player_stats(@row_count, @order_by, @order_desc)
		render :json => @player_stats
	end
end
