/**
* Name: NetLogoImple
* Based on the internal empty template. 
* Author: DELAUNAY
* Tags: 
*/


model NetLogoImple

/* Insert your model definition here */

global {
		
	grid_file dem_file <- file("../includes/DITTT_MNT_10m_u16_nepoui.tif");
	field terrain <- field(dem_file) ;
	matrix test <- matrix(terrain);
	string dis <- 'aled';

	
	field flow <- field(terrain.columns,terrain.rows);
	list<point> points <- flow points_in shape;
	
	list<point> water_cells <- [];
	list<point> earth_cells <- [];
	
	map<point, float> heights <- [];
	float diffusion_rate <- 0.8;
	
	int frequence_input <- 3;
	float rainfall <- 0.33;
	float soil_hardness <- 0.75;
	int RES <- 10;
	bool fill <- false;
		
	map<point, list<point>> neighbors <- points as_map (each::(flow neighbors_of each));
	map<point, bool> done <- points as_map (each::false);
	map<point, float> h <- points as_map (each::terrain[each]);
	
	init {
		float c_h <- shape.height/flow.rows;
		list<point>  ero_pt <- points where (terrain[each] < 10.0) ;
		loop pt over: ero_pt  {
			if (pt.y <  (c_h)) {
				water_cells <<pt;
			}
		}	
		loop pt over: ero_pt  {
			if (pt.y > (shape.height - (c_h) )) {
				earth_cells <<pt;
			}
		}	
		
	}
	
	//Reflex to add water among the water cells
	reflex adding_input_water when: every(frequence_input#cycle){
		loop p over: water_cells {
			flow[p] <- flow[p] ;
		}
	}
	
	float height (point c) {
		return h[c] + flow[c];
	}
	
	reflex flowing {
		done[] <- false;
		heights <- points as_map (each::height(each));
		list<point> val1 <- points sort_by (heights[each]);
		list<point> target  <- list<point>(val1 min_of(flow[each]));
		loop p over: points - target {
			done[p] <- true;
		}
		loop p over: points{
			float height <- height(p);
			/*int amount <- min( float(points[self]) , float((0.5 * (height[self] + flow[self] - height[p] -flow[p] ))));
			
			if (amount > 0) {
				float erosion <- amount * (1 - soil_hardness);
				height  <- height - erosion ;
				amount <- min( flow[each] , float((0.5 * (height[each] + flow[each] - height[p] -flow[p] ))));
				flow[p] <- flow[p] - amount;
				flow <- flow + amount;
			}*/
		}
	}
	reflex b{
		
		do debug("aled");
	}
	reflex c{
		write "ceci est le terrain" + terrain ;
	}
	
}



experiment Ero type: gui {
	output {
		display c {}
	}
}



