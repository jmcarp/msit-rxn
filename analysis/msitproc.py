import os, re
import mspec
from pylab import *
import scipy.stats
import copy

scriptdir = '/data/2/jmc/scripts/msit'
behavdir = '/data/2/jmc/data/msit/behav'
specdir = '/data/2/jmc/data/msit/spec'

stderr = lambda v: std(v) / sqrt(len(v))

condrules = {
  'msit-con' : lambda t: t['task'] == 'msit' and t['ttype'] == 'con', 
  'msit-inc' : lambda t: t['task'] == 'msit' and t['ttype'] == 'inc', 
  'simple' : lambda t: t['task'] == 'simple'
}
condnames = [ 'msit-con', 'msit-inc', 'simple']

bcondrules = {
  'con' : lambda t: t['task'] == 'msit' and t['ttype'] == 'con', 
  'inc' : lambda t: t['task'] == 'msit' and t['ttype'] == 'inc', 
  'simp' : lambda t: t['task'] == 'simple',
  'coniti0' : lambda t: t['task'] == 'msit' and t['ttype'] == 'con' and t['itin1'] == '0',
  'coniti1' : lambda t: t['task'] == 'msit' and t['ttype'] == 'con' and t['itin1'] == '1250',
  'coniti2' : lambda t: t['task'] == 'msit' and t['ttype'] == 'con' and t['itin1'] == '2500',
  'coniti3' : lambda t: t['task'] == 'msit' and t['ttype'] == 'con' and t['itin1'] == '3750',
  'coniti4' : lambda t: t['task'] == 'msit' and t['ttype'] == 'con' and t['itin1'] == '5000',
  'inciti0' : lambda t: t['task'] == 'msit' and t['ttype'] == 'inc' and t['itin1'] == '0',
  'inciti1' : lambda t: t['task'] == 'msit' and t['ttype'] == 'inc' and t['itin1'] == '1250',
  'inciti2' : lambda t: t['task'] == 'msit' and t['ttype'] == 'inc' and t['itin1'] == '2500',
  'inciti3' : lambda t: t['task'] == 'msit' and t['ttype'] == 'inc' and t['itin1'] == '3750',
  'inciti4' : lambda t: t['task'] == 'msit' and t['ttype'] == 'inc' and t['itin1'] == '5000',
  'simpiti0' : lambda t: t['task'] == 'simple' and t['itin1'] == '0',
  'simpiti1' : lambda t: t['task'] == 'simple' and t['itin1'] == '1250',
  'simpiti2' : lambda t: t['task'] == 'simple' and t['itin1'] == '2500',
  'simpiti3' : lambda t: t['task'] == 'simple' and t['itin1'] == '3750',
  'simpiti4' : lambda t: t['task'] == 'simple' and t['itin1'] == '5000',
}

excconds = [
  lambda t: t['acc'] != 'hit'
]

accexcconds = [
  lambda t: t['acc'] == 'miss',
]
rtexcconds = [
  lambda t: t['acc'] != 'hit',
]

behavaccexcconds = [
  lambda t: t['acc'] == 'miss' and t['task'] == 'msit'
]
#  lambda t: t['acc'] == 'miss' and t['task'] == 'msit'
behavrtexcconds = [
  lambda t: t['acc'] != 'hit'
]

sdtrim = 3

params = [
  { 'name' : 'rt',
    'poly' : 1,
    'center' : True
  }
]

params_poly = [
  { 'name' : 'rt',
    'poly' : 3,
    'center' : True
  }
]

def behavstats():
  
  res = {
    'rt' : analyzegroup(condrules, dv='rt'),
    'acc' : analyzegroup(condrules, dv='acc')
  }

  for restype in ['rt', 'acc']:

    print 'Inc > Con (%s)' % (restype), \
      mean(res[restype]['msit-inc']), stderr(res[restype]['msit-inc']), \
      mean(res[restype]['msit-con']), stderr(res[restype]['msit-con']), \
      mean(res[restype]['msit-inc'] - res[restype]['msit-con']), \
      scipy.stats.ttest_1samp(res[restype]['msit-inc'] - res[restype]['msit-con'], 0)

    print 'Inc > Simp (%s)' % (restype), \
      mean(res[restype]['msit-inc']), stderr(res[restype]['msit-inc']), \
      mean(res[restype]['simple']), stderr(res[restype]['simple']), \
      mean(res[restype]['msit-inc'] - res[restype]['simple']), \
      scipy.stats.ttest_1samp(res[restype]['msit-inc'] - res[restype]['simple'], 0)

    print 'Con > Simp (%s)' % (restype), \
      mean(res[restype]['msit-con']), stderr(res[restype]['msit-con']), \
      mean(res[restype]['simple']), stderr(res[restype]['simple']), \
      mean(res[restype]['msit-con'] - res[restype]['simple']), \
      scipy.stats.ttest_1samp(res[restype]['msit-con'] - res[restype]['simple'], 0)

def checkomit():
  
  # 
  subjs = [x for x in os.listdir(behavdir) if re.search('^\d{6}\w{2}$', x)]
  subjs = sorted(subjs)

  for subj in subjs:
    sess = readall(subj)
    for run in sess:
      mspec.cleanFld(run, behavaccexcconds)
      mspec.cleanRT(run, condrules, sdtrim)
      omittrials = [t for t in run if t['task'] == 'simple' and t['acc'] == 'miss']
      if omittrials:
        print len(omittrials)

def rthist_plot():
  
  rts = rthist_group()
  
  h0 = hist(rts['msit-inc'] + rts['simple'], 50)
  clf()
  
  hist(rts['msit-con'], h0[1], alpha=0.7, color='blue')
  hist(rts['msit-inc'], h0[1], alpha=0.7, color='red')

  p0 = Rectangle((0, 0), 1, 1, fc='blue')
  p1 = Rectangle((0, 0), 1, 1, fc='red')

  legend((p0, p1), ('simple', 'msit-inc'))

def rthist_group():
  
  subjs = [x for x in os.listdir(behavdir) if re.search('^\d{6}\w{2}$', x)]
  subjs = sorted(subjs)
  
  rts = {}
  for cond in condrules:
    rts[cond] = []

  for subj in subjs:
    print subj
    subj_rts = rthist_subj(subj)
    for cond in condrules:
      rts[cond] += subj_rts[cond]

  return rts

def rthist_subj(subjname):
  
  runs = readall(subjname)
  trials = reduce(lambda x, y: x + y, runs, [])

  mspec.cleanFld(trials, behavrtexcconds)
  inctrials = [t for t in trials if t['include']]

  all_rts = array([t['rt'] for t in inctrials])
  mean_rt = all_rts.mean()
  std_rt = all_rts.std()

  for t in inctrials:
    t['zrt'] = (t['rt'] - mean_rt) / std_rt

  rts = {}
  for cond in condrules:
    rts[cond] = [t['zrt'] for t in inctrials if condrules[cond](t)]

  return rts

def analyzegroup(condrules, dv='rt'):
  
  # 
  subjs = [x for x in os.listdir(behavdir) if re.search('^\d{6}\w{2}$', x)]
  subjs = sorted(subjs)
  
  # Initialize 
  res = {}
  for cond in condrules:
    res[cond] = array([])

  # 
  for subj in subjs:
    subjres = analyzesubj(subj, condrules, dv=dv)
    for cond in condrules:
      res[cond] = append(res[cond], subjres[cond])

  return res

def analyzesubj(subjname, condrules, dv='rt'):
  
  if dv == 'rt':
    tmpexcconds = behavrtexcconds
  elif dv == 'acc':
    tmpexcconds = behavaccexcconds
  else:
    print 'Invalid DV: %s' % (dv)
    return
  
  trials = []
  sess = readall(subjname)
  for run in sess:
    mspec.cleanFld(run, tmpexcconds)
    mspec.cleanRT(run, condrules, sdtrim)
    trials.extend(run)
  
  inctrials = [t for t in trials if 'include' not in t 
    or t['include']]
  
  res = {}
  for cond in condrules:
    condtrials = [t for t in inctrials if condrules[cond](t)]
    if dv == 'rt':
      res[cond] = mean([t['rt'] for t in condtrials if t['rt']])
    elif dv == 'acc':
      res[cond] = len([t for t in condtrials if t['acc'] == 'hit']) / float(len(condtrials))

  return res

def batch():
  
  subjs = [x for x in os.listdir(behavdir) if re.search('^\d{6}\w{2}$', x)]
  subjs = sorted(subjs)
  
  expt = {}
  
  for subj in subjs:

    print 'Working on subject %s...' % (subj)
    
    sess = readall(subj)
    for run in sess:
      mspec.cleanFld(run, excconds)
      mspec.cleanRT(run, condrules, sdtrim)
    specname = '%s/model_%s.m' % (specdir, subj)
    mspec.writespec(specname, sess, \
      condnames, condrules, params=params, modelExc=True)
    # With polynomial expansion
    specname = '%s/model_poly_%s.m' % (specdir, subj)
    mspec.writespec(specname, sess, \
      condnames, condrules, params=params_poly, modelExc=True)
    # 
    specname = '%s/model_fir_%s.m' % (specdir, subj)
    mspec.writespec(specname, sess, \
      condnames, condrules, params=params, modelExc=True, offset=-8*1.25)
    expt[subj] = sess

def writebehav():
  
  subjs = [x for x in os.listdir(behavdir) if re.search('^\d{6}\w{2}$', x)]
  subjs = sorted(subjs)
  
  expt = {}

  out = open('%s/behav.m' % (scriptdir), 'w')
  
  for subj in subjs:

    print 'Working on subject %s...' % (subj)
    
    sess = readall(subj)
    for run in sess:
      run = mspec.addadj(run, 'iti', -1)
      print run[0].keys()
    acctrials = []
    rttrials = []

    for run in sess:
      
      accrun = copy.deepcopy(run)
      mspec.cleanFld(accrun, accexcconds)
      mspec.cleanRT(accrun, condrules, sdtrim)
      acctrials.extend(accrun)

      rtrun = copy.deepcopy(run)
      mspec.cleanFld(rtrun, rtexcconds)
      mspec.cleanRT(rtrun, condrules, sdtrim)
      rttrials.extend(rtrun)
    
    for cond in bcondrules:
      
      ccond = cond.replace('-', '')
      
      acccondtrials = [t for t in acctrials \
        if bcondrules[cond](t) and t['include']]
      meanacc = len([t for t in acccondtrials \
        if t['acc'] == 'hit']) / float(len(acccondtrials))
      out.write('acc.%s.s%s = %f;\n' % \
        (ccond, subj, meanacc))

      rtcondtrials = [t for t in rttrials \
        if bcondrules[cond](t) and t['include']]
      meanrt = sum([t['rt'] for t in rtcondtrials]) \
        / float(len(rtcondtrials))
      out.write('rt.%s.s%s = %f;\n' % \
        (ccond, subj, meanrt))
  
  out.close()

def readall(subjname):
  
  logdir = '%s/%s' % (behavdir, subjname)
  subjfiles = [file for file in os.listdir(logdir) \
    if re.search('\.log$', file)]

  subjfiles.sort(key = lambda x: \
    int(os.path.getmtime('%s/%s' % (logdir, x))))
  
  sess = []
  for file in subjfiles:
    log = readlog('%s/%s' % (logdir, file))
    if re.search('simple', file):
      task = 'simple'
    else:
      task = 'msit'
    for trial in log:
      trial['task'] = task
    sess.append(log)
    
  return sess

def readmsit(subjname):
  
  subjfiles = [file for file in os.listdir(logdir) \
    if re.search('%s-msit\.+log$' % subjname, file)]
  
  trials = []
  for file in subjfiles:
    log = readlog('%s/%s' % (logdir, file))
    trials.extend(log)
  
  return trials

def readsimple(subjname):
  
  subjfiles = [file for file in os.listdir(logdir) \
    if re.search('%s-msit-simple\.+log$' % subjname, file)]

  trials = []
  for file in subjfiles:
    log = readlog('%s/%s' % (logdir, file))
    trials.extend(log)
  
  return trials

def readlog(logname):
  
  lines = open(logname, 'r').readlines()
  lines = [line.strip().split('\t') for line in lines]

  manlines = [l for l in lines if len(l) >= 3 and l[2] == 'Manual']
  runstart = float(manlines[0][4])
  runstop = float(manlines[-1][4])

  for lineidx in range(len(lines)):
    if lines[lineidx][0] == 'Event Type':
      lines = lines[lineidx + 2:]
      break
  
  trials = []
  for line in lines:
    trial = dict([field.split(':') for field in line[1].split('|')])
    trial['acc'] = line[2]
    if trial['acc'] in ['hit', 'incorrect']:
      trial['rt'] = float(line[4]) / 10
    else:
      trial['rt'] = None
    trial['onset'] = (float(line[6]) - runstart) / 10000 - 6.25
    trials.append(trial)
  
  return trials
