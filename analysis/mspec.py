import os, re
from pylab import *

def writespec(specname, sess, condnames, condrules, \
  params=[], addDur=False, modelExc=False, offset=0):

  # Open spec file
  spec = open(specname, 'w')

  for runidx in range(len(sess)):
    
    trials = [t for t in sess[runidx] if 'include' not in t \
      or t['include'] == True]
    exctrials = [t for t in sess[runidx] if 'include' in t \
      and t['include'] == False]
    
    dispcondidx = 0
    for condidx in range(len(condnames)):
      
      condname = condnames[condidx]
      condtrials = [t for t in trials if condrules[condname](t)]

      if not condtrials:
        continue
      
      dispcondidx += 1
      
      # Write condition name
      outstr = 'spec{%d}{%d}.name = \'%s\';\n' % \
        (runidx + 1, dispcondidx, condname)
      spec.write(outstr)
      
      # Write onsets
      outstr = 'spec{%d}{%d}.onset = [%s];\n' % \
        (runidx + 1, dispcondidx, \
        ' '.join([str(t['onset'] + offset) for t in condtrials]))
      spec.write(outstr)
      
      # Write parameters
      for paramidx in range(len(params)):
        param = params[paramidx]
        parval = [t[param['name']] for t in condtrials]
        if param['center'] == True:
          parval = [p - mean(parval) for p in parval]
        outstr = 'spec{%d}{%d}.param(%d) = struct(' % \
          (runidx + 1, dispcondidx, paramidx + 1) + \
          '\'name\', \'%s\', \'poly\', %d, ' % \
          (param['name'], param['poly']) + \
          '\'param\', [%s]);\n' % \
          (' '.join([str(p) for p in parval]))
        spec.write(outstr)
          
      # Write durations
      if addDur:
        outstr = 'spec{%d}{%d}.dur = [%s];\n' % \
          (runidx + 1, dispcondidx, \
          ' '.join([str(t['duration']) for t in condtrials]))
        spec.write(outstr)

    if modelExc and len(exctrials) > 0:
      
      dispcondidx += 1
      
      outstr = 'spec{%d}{%d}.name = \'other\';\n' % \
        (runidx + 1, dispcondidx)
      spec.write(outstr)
      
      outstr = 'spec{%d}{%d}.onset = [%s];\n' % \
        (runidx + 1, dispcondidx, \
        ' '.join([str(t['onset']) for t in exctrials]))
      spec.write(outstr)

      if addDur:
        outstr = 'spec{%d}{%d}.dur = [%s];\n' % \
          (runidx + 1, dispcondidx, \
          ' '.join([str(t['duration']) for t in exctrials]))
        spec.write(outstr)

  # Close spec file
  spec.close()

def cleanFld( trials, excConds, marker='include', verbose=True ):
  excCt = 0
  for trial in trials:
    if marker not in trial or trial[marker]:
      trial[marker] = True not in [ cond(trial) for cond in excConds ]
      if not trial[marker]:
        excCt += 1
  if verbose:
    print 'Cleaning trials...'
    print '\t%d trials excluded' % excCt

def cleanRT( trials, rtConds, sdCutoff, marker='include', minTrials=5, verbose=True ):
  """Mark RT outliers
  Examples:
    # Mark RT outliers 2.5 standard deviations from their conditional mean
    # Require at least ten trials to estimate standard deviation
    # Do not provide text output
    cleanRT(trials, rtConds, 2.5, minTrials=10, verbose=False)
  Arguments:
    trials: a list of trial dictionary objects
    rtConds: a dictionary of condition tests, e.g.:
      rtConds = {}
      rtConds['alt_con'] = lambda t: t['switch'] == 'alt' and t['ccong'] == 'congruent'
      rtConds['alt_inc'] = lambda t: t['switch'] == 'alt' and t['ccong'] == 'incongruent'
    sdCutoff: number of standard deviations for RT cutoff
    marker: name of the trial parameter to use for marking RT outliers
      default: 'include'
    minTrials: minimum number of trials to estimate SD
      default: 5
    verbose: [True|False] give detailed text output?"""
  # Process each condition in <rtConds>
  for cond in rtConds:
    # Identify trials that match the selected condition
    # Put in <matchTrials>
    matchTrials = [ t for t in trials if rtConds[cond](t) and (marker not in t or t[marker]) and t['rt'] ]
    # If there aren't enough trials in this condition to estimate SD, include all trials
    if len(matchTrials) < minTrials:
      for trial in matchTrials:
        trial[marker] = True
      if verbose:
        print 'Less than %d trials available for condition %s' % ( minTrials, cond )
        print '\tIncluding all trials'
    # If there are enough trials in this condition to estimate SD, remove outliers
    else:
      # Get RT distribution
      rts = [ t['rt'] for t in matchTrials if t['rt'] ]
      m = mean( rts )
      s = std( rts ) * sdCutoff
      excCt = 0
      # Mark outlier trials
      for trial in matchTrials:
        if marker not in trial or trial[marker]:
          trial[marker] = m - s <= trial['rt'] <= m + s
          if not trial[marker]:
            excCt += 1
      if verbose:
        print 'RT window: %4.1fms to %4.1fms' % ( m - s, m + s )
        print '\t%d trials excluded' % excCt

def addadj(trials, field, offset):
  
  if offset > 0:
    adjfield = '%sp%d' % (field, offset)
  else:
    adjfield = '%sn%d' % (field, abs(offset))
  for tidx in range(len(trials)):
    tadj = tidx + offset
    if tadj >= 0 and tadj < len(trials):
      trials[tidx][adjfield] = \
        trials[tadj][field]
    else:
      trials[tidx][adjfield] = None

  return trials
