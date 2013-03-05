# Response parameters
active_buttons = 3;
button_codes = 1, 2, 3;
response_matching = simple_matching;

# Trigger parameters
write_codes = true;
pulse_width = 1;

###########
### SDL ###
###########

begin;

picture {
	text { caption = "+"; font_size = 48; font = "Arial"; };
	x = 0; y = 0;
} fixpic;

trial {
	picture fixpic;
} ftrial;

trial {
	stimulus_event {
		picture {
			polygon_graphic {} mspoly;
			x = 0; y = 0;
		} mspic;
		port_code = 255;
	} msevt;	
} mstrial;

trial {
	
	trial_type = specific_response;
	trial_duration = forever;
	terminator_button = 1;
	
	picture {
		text { caption = " "; font_size = 24; } itxt;
		x = 0; y = 0;
	};
	
} itrial;

trial {
	
	trial_type = specific_response;
	trial_duration = forever;
	terminator_button = 2;
	
	picture {
		text { caption = " "; font_size = 24; } wtxt;
		x = 0; y = 0;
	};
	
} wtrial;

###########
### PCL ###
###########

begin_pcl;

# Include miscellaneous utility functions
include "../../util.pcl";

##################
### Parameters ###
##################

int tdur = 2500;				# Total trial duration (ms)
int sdur = 500;				# Stimulus duration (ms)
int textoff = 75;
int maxiti = 4;
int tr = 1250;

double radius = 50.0;
string tgtfont = "Arial";
int fontsize = 96;

int ntrials = 200;			# Number of trials per block

int onstime = 0;				# Initial onset time

# Set stimulus duration
msevt.set_duration(sdur);
mstrial.set_duration(tdur - 100);

# Set correct button
msevt.set_target_button(1);

# Set shape params
mspoly.set_radius(radius);

#########################
### Utility functions ###
#########################

# Present instructions
sub instruct( string txt ) begin;
	
	itxt.set_caption( txt );
	itxt.redraw();
	itrial.present();
	
end;

# Present wait screen
sub wait( string txt ) begin;
	
	wtxt.set_caption( txt );
	wtxt.redraw();
	wtrial.present();
	
end;

# Show fixation cross
sub showfix ( int dur ) begin;
	
	ftrial.set_duration(dur);
	ftrial.present();
	
end;

sub array<int,1> getiti(int niti) begin;
	
	int nadd = niti;
	array<int> iti[0];
	
	loop int itiidx = 0 until itiidx > maxiti begin;
		nadd = int(ceil(double(nadd) / 2.0));
		loop int addidx = 1 until addidx > nadd begin;
			iti.add(itiidx);
			addidx = addidx + 1;
		end;
		itiidx = itiidx + 1;
	end;
	
	return iti;
	
end;

sub dotrial (int nsides, int iti, int trialidx, int blockidx) begin;
	
	# Set sides
	mspoly.set_sides(nsides);
	mspoly.redraw();
	
	# Set event code
	string code;
	code = code + "nsides:" + string(nsides);
	code = code + "|onstime:" + string(onstime);
	code = code + "|iti:" + string(iti * tr);
	code = code + "|trialidx:" + string(trialidx);
	code = code + "|blockidx:" + string(blockidx);
	msevt.set_event_code(code);
	
	# Present trial
	mstrial.set_start_time(onstime);
	onstime = onstime + tdur + iti * tr;
	mstrial.present();
	
end;

sub doblock (int nblocktrials, int blockidx) begin;
	
	# Make trials
	ntrials = int(ceil(double(nblocktrials) / 24.0) * 24.0);
	
	array<int> itilist[ntrials / 2];
	itilist = getiti(ntrials / 2);
	itilist.append(itilist);
	
	array<int> trialpos[ntrials];
	trialpos.fill(1, ntrials, 1, 1);
	trialpos.shuffle();
	
	# Present trials
	int nsides, iti;
	loop int trialidx = 1 until trialidx > ntrials begin;
		nsides = mod(trialpos[trialidx], 4) + 1 + 2;
		if trialidx == 1 then;
			iti = 0;
		else;
			iti = itilist[trialpos[trialidx]];
		end;
		dotrial(nsides, iti, trialidx, blockidx);
		trialidx = trialidx + 1;
	end;
	
end;

############
### Main ###
############

# Set task onset time
onstime = clock.time() + 500;

doblock(24, 1);