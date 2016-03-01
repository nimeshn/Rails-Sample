require "nokogiri"

module StatsHelper
	
	# get emptystr if xml node doesn't exist
	def assign_if_null(node)
		node ? node.content : ""
	end
	
	# gets the xml data from the file and creates a players hash
	def fetch_data_from_xml_file
		players = []
		doc = File.open("./app/assets/data/1998statistics.xml") { |f| Nokogiri::XML(f) }
		
		# traversing the xml tree using css path
		doc.css("SEASON").each do |season|
			season.css("LEAGUE").each do |league|
				league.css("DIVISION").each do |division|
					division.css("TEAM").each do |team|
						team.css("PLAYER").each do |xml_player|
							# create a new Player Hash 
							player = Hash.new(nil)
							player[:year] = assign_if_null season.at_css("YEAR")
							player[:league_name] = assign_if_null league.at_css("LEAGUE_NAME")
							player[:division_name] = assign_if_null division.at_css("DIVISION_NAME")
							player[:team_name] = assign_if_null team.at_css("TEAM_NAME")
							player[:team_city] = assign_if_null team.at_css("TEAM_CITY")
							player[:surname] = assign_if_null xml_player.at_css("SURNAME")
							player[:given_name] = assign_if_null xml_player.at_css("GIVEN_NAME")
							player[:position] = assign_if_null xml_player.at_css("POSITION")
							player[:home_runs] = assign_if_null xml_player.at_css("HOME_RUNS")
							player[:rbi] = assign_if_null xml_player.at_css("RBI")
							player[:runs] = assign_if_null xml_player.at_css("RUNS")
							# calculate batting average 
							hits = assign_if_null xml_player.at_css("HITS")
							at_bats = assign_if_null xml_player.at_css("AT_BATS")							
							player[:avg] = (hits.to_f/at_bats.to_f).round(4) if hits != "" && at_bats!= "" && at_bats.to_f != 0
							# calculate Stolen Base %age
							steals = assign_if_null xml_player.at_css("STEALS")
							caught_stealing = assign_if_null xml_player.at_css("CAUGHT_STEALING")							
							player[:sbp] = (steals.to_f * 100/(steals.to_f + 
								(caught_stealing != ""? caught_stealing.to_f : 0))).round(2) if steals!="" && steals.to_f != 0
							# Calculate OPS  (HITS + WALKS + HIT_BY_PITCH)/(AT_BATS + WALKS + HIT_BY_PITCH + SACRIFICE_FLIES)
							walks = assign_if_null xml_player.at_css("WALKS")
							hit_by_pitch = assign_if_null xml_player.at_css("HIT_BY_PITCH")
							sacrifice_flies = assign_if_null xml_player.at_css("SACRIFICE_FLIES")
							if (hits!="" || walks!="" || hit_by_pitch!="") && 
							(at_bats!="" || walks!="" || hit_by_pitch!=""  || sacrifice_flies!="")
								$numerator = (hits!=""? hits.to_f : 0) +
									(walks!=""? walks.to_f : 0) +
									(hit_by_pitch!=""? hit_by_pitch.to_f : 0)
								$denominator = (at_bats!=""? at_bats.to_f : 0) +
									(walks!=""? walks.to_f : 0) +
									(hit_by_pitch!=""? hit_by_pitch.to_f : 0) + 
									(sacrifice_flies!=""? sacrifice_flies.to_f : 0)
								if $denominator > 0
									player[:ops] = ($numerator/$denominator).round(4)
								end
							end
							# push these into the players array
							players << player
						end
					end
				end
			end
		end
		
		return players
	end

	# calls fetch_data_from_xml_file and caches it 
	def get_player_stats(row_count=25, order_by="AVG", desc=true)		
		order_by.downcase!
		order_by = order_by.to_sym()
		# get Players hash from cache or call fetch_data_from_xml_file on cache miss
		players = Rails.cache.fetch("xml_flattened_data", :expires_in => 1.hour) { fetch_data_from_xml_file }
		# filter players for nil/empty values on order_by field
		players = players.select {|player| true if player[order_by] != nil && player[order_by] != ""}
		# ok lets sort 
		players.sort_by! {|player| 
			case order_by
				when :home_runs,:rbi,:runs,:avg,:sbp,:ops then player[order_by].to_f # sort as float if float valued field
				else player[order_by] # else simple string sort
			end
		}
		# reverse sort if desc
		players.reverse! if desc
		# slice it for row_count 
		return players[0,row_count]
	end
end

