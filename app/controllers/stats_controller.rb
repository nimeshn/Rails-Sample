class StatsController < ApplicationController
	include StatsHelper

	def index
		@row_count = params[:row_count]
		@order_by = params[:order_by]
		@order_desc = params[:order_desc]
		@order_by ||= 'avg'
		@order_desc ||= true
		@row_count ||= 25
		@player_stats = get_data(@row_count, @order_by, @order_desc)
	end

	def ordered_data
		@row_count = params[:row_count].to_i
		@order_by = params[:order_by]
		@order_desc = params[:order_desc] == "true"
		@player_stats = get_data(@row_count, @order_by, @order_desc)
		render :json => @player_stats
	end
end
