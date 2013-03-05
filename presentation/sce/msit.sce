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

polygon_graphic {
	sides = 100;
	radius = 5;
	line_color = 255, 0, 0;
	fill_color = 255, 0, 0;
} fixpoly;

picture {
	polygon_graphic fixpoly;
	x = 0; y = 0;
} default;

trial {
	picture {
		polygon_graphic fixpoly;
		x = 0; y = 0;
	};
} ftrial;

trial {
	stimulus_event {
		picture {
			text { caption = " "; } mstext_lt;
			x = 0; y = 0;
			text { caption = " "; } mstext_ct;
			x = 0; y = 0;
			text { caption = " "; } mstext_rt;
			x = 0; y = 0;
			polygon_graphic fixpoly;
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
int textoff = 100;
int maxiti = 4;
int tr = 1250;
int disdaq = 5;
int ntrpost = 10;

string tgtfont = "Arial";
int fontsize = 144;

int ntrials = 200;			# Number of trials per block

array<int> ctrials[3][3];
ctrials[1] = { 1, 0, 0 };
ctrials[2] = { 0, 2, 0 };
ctrials[3] = { 0, 0, 3 };

array<int> itrials[12][3];
itrials[1] =  { 2, 1, 2 };
itrials[2] =  { 2, 2, 1 };
itrials[3] =  { 3, 1, 3 };
itrials[4] =  { 3, 3, 1 };
itrials[5] =  { 2, 1, 1 };
itrials[6] =  { 2, 1, 2 };
itrials[7] =  { 2, 3, 3 };
itrials[8] =  { 3, 3, 2 };
itrials[9] =  { 3, 1, 1 };
itrials[10] = { 1, 3, 1 };
itrials[11] = { 3, 2, 2 };
itrials[12] = { 2, 3, 2 };

int onstime = 0;				# Initial onset time

# Set stimulus duration
msevt.set_duration(sdur);
mstrial.set_duration(tdur - 100);

# Set text offset
mspic.set_part_x(1, -1 * textoff);
mspic.set_part_x(3, 1 * textoff);

# Set font params
mstext_lt.set_font(tgtfont);
mstext_lt.set_font_size(fontsize);
mstext_ct.set_font(tgtfont);
mstext_ct.set_font_size(fontsize);
mstext_rt.set_font(tgtfont);
mstext_rt.set_font_size(fontsize);

#########################
### Utility functions ###
#########################

# Present instructions
sub instruct( string txt ) begin;
	
	itxt.set_caption( txt );
	itxt.redraw();
	itrial.present();
	
end;

# Show fixation cross
sub showfix ( int dur, int onsinc ) begin;
	
	onstime = onstime + onsinc;
	ftrial.set_start_time(onstime);
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
			if iti.count() >= niti then;
				break;
			end;
		end;
		itiidx = itiidx + 1;
	end;
	
	loop int addidx = iti.count() + 1 
		until addidx > niti begin;
		iti.add(maxiti);
		addidx = addidx + 1;
	end;
	
	return iti;
	
end;

sub dotrial (int dig_lt, int dig_ct, int dig_rt, int iti, int trialidx, int blockidx) begin;
	
	# Set text
	mstext_lt.set_caption(string(dig_lt));
	mstext_lt.redraw();
	mstext_ct.set_caption(string(dig_ct));
	mstext_ct.redraw();
	mstext_rt.set_caption(string(dig_rt));
	mstext_rt.redraw();
	
	int tgtdig, disdig;
	if dig_lt == dig_ct then;
		tgtdig = dig_rt;
		disdig = dig_lt;
	elseif dig_lt == dig_rt then;
		tgtdig = dig_ct;
		disdig = dig_lt;
	elseif dig_ct == dig_rt then;
		tgtdig = dig_lt;
		disdig = dig_ct;
	end;
	
	# Set correct button
	msevt.set_target_button(tgtdig);
	
	string ttype;
	if disdig == 0 then;
		ttype = "con";
	else;
		ttype = "inc";
	end;
	
	# Set event code
	string code;
	code = code + "dig_lt:" + string(dig_lt);
	code = code + "|dig_ct:" + string(dig_ct);
	code = code + "|dig_rt:" + string(dig_rt);
	code = code + "|tgtdig:" + string(tgtdig);
	code = code + "|disdig:" + string(disdig);
	code = code + "|ttype:" + ttype;
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
	array<int> tlist[0][3];
	loop int cidx = 1 until cidx > (ntrials / 2) / 3 begin;
		tlist.append(ctrials);
		cidx = cidx + 1;
	end;
	loop int iidx = 1 until iidx > (ntrials / 2) / 12 begin;
		tlist.append(itrials);
		iidx = iidx + 1;
	end;
	
	array<int> itilist[ntrials / 2];
	itilist = getiti(ntrials / 2);
	itilist.append(itilist);
	
	array<int> trialpos[ntrials];
	trialpos.fill(1, ntrials, 1, 1);
	trialpos.shuffle();
	
	# Present trials
	array<int> t[3];
	int iti;
	loop int trialidx = 1 until trialidx > ntrials begin;
		t = tlist[trialpos[trialidx]];
		iti = itilist[trialpos[trialidx]];
		dotrial(t[1], t[2], t[3], iti, trialidx, blockidx);
		trialidx = trialidx + 1;
	end;
	
end;

############
### Main ###
############

# Initialize display
showfix(1, 25);

# Get parallel port
if (output_port_manager.port_count() == 0) then
   term.print("Forgot to add an output port!");
end;
output_port pport = output_port_manager.get_port(1);

# Send parallel trigger
pport.send_code(255);

# Send start code
logfile.add_event_entry("START");

# Set task onset time
onstime = clock.time() + disdaq * tr;

# Show trials
doblock(96, 1);

# Show post-block fixation
showfix(ntrpost * tr, 0);

# Clear parallel port
pport.send_code(0);

# Send end code
logfile.add_event_entry("END");