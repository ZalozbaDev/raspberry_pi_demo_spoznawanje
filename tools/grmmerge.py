#!/usr/bin/env python3

import sys,os,subprocess,re

class Obj:
    def __init__(self,**kwargs):
        self.dct=kwargs
        for k,v in kwargs.items(): object.__setattr__(self,k,v)
    def __setattr__(self,k,v):
        if k!='dct': self.dct[k]=v
        object.__setattr__(self,k,v)

def finddlp():
    dns=[]
    if 'DLABPRO_HOME' in os.environ:
        dns.append(os.path.join(os.environ['DLABPRO_HOME'],'bin.release'))
    if 'UASR_HOME' in os.environ:
        for dn in os.environ['UASR_HOME'], os.path.realpath(os.environ['UASR_HOME']):
            dns.append(os.path.realpath(os.path.join(dn,'..','dlabpro','bin.release')))
            dns.append(os.path.realpath(os.path.join(dn,'..','dLabPro','bin.release')))
    dns+=os.environ['PATH'].split(';')
    for dn in dns:
        for fn in 'dlabpro.exe','dlabpro':
            fn=os.path.join(dn,fn)
            if os.path.exists(fn): return fn
    return 'dlabpro'

def grm2ofstarg(fin):
    ret=[]
    ret.append(os.path.join(os.path.dirname(sys.argv[0]),'grm2ofst.xtp'))
    ret.append(fin)
    dn=os.path.dirname(fin)
    bn=os.path.basename(fin)
    for fn in os.listdir(dn):
        if fn==bn or re.search('_(ofst(_[io]s)?|seqs).txt$',fn): continue
        m=re.match('^(.*).TXT$',fn,flags=re.IGNORECASE)
        if not m is None: ret.append(m[1])
    return ret

def loadgrm(fn,sub=False):
    split = (lambda s:re.split('[ \t]+',s)) if sub else (lambda s:s.split('\t'))
    with open(fn,'r',encoding=enc) as f: grm=[split(l.strip()) for l in f.readlines()]
    if sub:
        grm=[l for l in grm if len(l)>1 or l[0]!='']
        grm=[(l+[0] if len(l)==4 else l) for l in grm]
        grm=[(l+[0] if len(l)==5 else l) for l in grm]
    for l in grm:
        if len(l)==5: raise SystemExit('Please use at least dLabPro git version db0da22')
        if len(l) not in (1,2,6): raise SystemExit('Unkown format error')
    sini=int(grm[0][0])
    smap=lambda s:sini if s==0 else (0 if s==sini else s)
    smapi=lambda s:smap(int(s))
    td=[
        Obj(**{k:t(v) for k,t,v in zip('seiowk',(smapi,smapi,str,str,float,int),l)})
        for l in grm if len(l)==6
    ]
    sfin=set(map(smapi,(l[0] for l in grm if len(l)==1)))
    tfin=[l for l in grm if len(l)==2]
    if len(tfin)!=0:
        sf=max(max(t.dct[k] for t in td for k in 'se'),*sfin,*[smapi(l[0]) for l in tfin])+1
        sfin.add(sf)
        for l in tfin: td.append(Obj(s=smapi(l[0]),e=sf,i='<eps>',o='<eps>',w=float(l[1]),k=0))
    return Obj(td=td,sd=sfin,ini=int(grm[0][0]),name=os.path.splitext(os.path.basename(fn))[0])

def grmsymupper(grm):
    for t in grm.td:
        if not t.i.startswith('<'): t.i=t.i.upper()
        if not t.o.startswith('<'): t.o=t.o.upper()

def grmmapistoos(grm):
    for t in grm.td:
        if t.i=='<eps>': continue
        if t.o=='<eps>': t.dct['o']=t.o=f'({t.i})'
        else: t.dct['o']=t.o=f'{t.o}({t.i})'

def grmaddpau(grm):
    grm.td+=[
        Obj(s=s,e=s,i='<PAU>',o='<eps>',w=0,k=0)
        for s in set(t.dct[k] for t in grm.td for k in 'se').union(grm.sd)
    ]

def grmapplylmw(grm,lmw):
    for t in grm.td: t.w=t.w*lmw

def savesym(fn,syms):
    if os.path.exists(fn):
        with open(fn,'r',encoding=enc) as f: fsyms=dict(map(lambda l:re.split('[ \t]+',l.strip()),f.readlines()))
        fsyms={k:v for k,v in fsyms.items() if k in syms}
    else: fsyms={}
    for k in sorted(syms):
        if not k in fsyms: fsyms[k]=''
    with open(fn,'w',encoding=enc) as f:
        for i,k in enumerate(fsyms):
            f.write(f'{k}\t{i}\n')

def savegrm(fn,grm):
    with open(fn,'w',encoding=enc) as f:
        for t in grm.td: f.write('\t'.join(map(str,(t.dct[k] for k in 'seiowk')))+'\n')
        for s in grm.sd: f.write(str(s)+'\n')
    savesym(re.sub('\\.txt$','',fn)+'_is.txt',set(t.i for t in grm.td))
    savesym(re.sub('\\.txt$','',fn)+'_os.txt',set(t.o for t in grm.td))

def mapstkgrm(grm,off):
    if off==0: return
    for t in grm.td:
        if   t.k<0: t.k-=off
        elif t.k>0: t.k+=off

def maxstkgrm(grm): return max(abs(t.k) for t in grm.td)

def mergesubgrms(grm,dn,depth=1,usestk=True):
    imps=[i for i in set(t.i for t in grm.td) if os.path.exists(os.path.join(dn,i+'.txt'))]
    # purely for more deterministic execution    
    imps.sort()
    for imp in imps:
        print(f'Merge {imp:15s} in {grm.name:15s} [Depth: {depth} Copies: {sum(t.i==imp for t in grm.td):2d}{"==>1" if usestk else ""}]')
        sgrm=loadgrm(os.path.join(dn,imp+'.txt'),sub=True)
        mergesubgrms(sgrm,dn,depth=depth+1,usestk=usestk and depth<maxstk)
        mergesubgrm(grm,imp,sgrm,usestk=usestk)

def mergesubgrm(grm,imp,sgrm,usestk=False):
    rpl=[t for t in grm.td if t.i==imp]
    if len(rpl)==0: return
    for t in rpl:
        if t.o not in (imp,'<eps>'): raise ValueError(f'Merging subgrammar "{imp}" with output symbol "{t.o}" not possible')
        if t.k!=0: raise ValueError(f'Merging subgrammar "{imp}" with stack symbol "{t.k}" not possible')
    grm.td=[t for t in grm.td if t.i!=imp]
    mapstkgrm(sgrm,maxstkgrm(grm))
    if len(rpl)==1: usestk=False
    tin=None; tout=[]
    for ti,t in enumerate(rpl):
        #print(f't: {t.s}=>{t.e} {t.i}:{t.o} {t.k}')
        if not usestk or tin is None:
            soff=max(set(t.dct[k] for t in grm.td for k in 'se').union(grm.sd))+1
            koff=maxstkgrm(grm)+1 if usestk else 0
            grm.td+=[Obj(**{**t.dct,'s':t.s+soff,'e':t.e+soff}) for t in sgrm.td]
            #print(f' ins {soff}=>'+','.join(str(e+soff) for e in sgrm.sd))
            tin=Obj(**{**t.dct,'e':sgrm.ini+soff,'i':'<eps>','o':f'[+{imp}]' if dbg else '<EPS>','k':koff})
            tout=[Obj(s=e+soff,e=t.e,i='<eps>',o=f'[-{imp}]' if dbg else '<EPS>',w=0.,k=-koff) for e in sgrm.sd]
            #for tx in (tin,*tout): print(f' t+  {tx.s}=>{tx.e} {tx.i}:{tx.o} {tx.k}')
            grm.td.append(tin)
            grm.td+=tout
        else:
            koff=maxstkgrm(grm)+1 if usestk else 0
            #tl=len(grm.td)
            grm.td.append(Obj(**{**tin.dct,'s':t.s,'o':f'[+{imp}]' if dbg else '<EPS>','w':t.w,'k':koff}))
            grm.td+=[Obj(**{**to.dct,'e':t.e,'o':f'[-{imp}]' if dbg else '<EPS>','k':-koff}) for to in tout]
            #for tx in grm.td[tl:]: print(f' t+  {tx.s}=>{tx.e} {tx.i}:{tx.o} {tx.k}')

def savelex(flex,fin):
    with open(fin,'r',encoding=enc) as fi, \
         open(flex,'w',encoding=enc) as fo:
        for l in fi.readlines():
            if l.startswith('LEX:'): fo.write(l[4:].strip()+'\n')


if len(sys.argv)<2:
    print(f'Usage: {sys.argv[0]} [-nostk] [-dbg] [-ofstin] [-addpau] [-lmw N] GRM.txt')
    print(f'  -nostk   Copy merged grammars instead of using stack symbols')
    print(f'  -dbg     Debug: Insert input symbols as (SYM) in output symbols + insert grammar begin and end as [+-GRM]')
    print(f'  -ofstin  GRM.txt is an openfst text file and not a UASR grammar')
    print(f'  -addpau  Add optional <PAU> between every word')
    print(f'  -lmw N   Set language model weight (default: 1)')
    raise SystemExit()
usestk=not '-nostk' in sys.argv
dbg='-dbg' in sys.argv
ofstin='-ofstin' in sys.argv
addpau='-addpau' in sys.argv
lmw=float(sys.argv[sys.argv.index('-lmw')+1]) if '-lmw' in sys.argv else 1
maxstk=1
fin=sys.argv[-1]
enc='utf-8'
fout=fin+'_ofst.txt'
flex=fin+'_lex.txt'
dn=os.path.dirname(fin)

if ofstin:
    subprocess.run(['cp',fin,fout],check=True)
else:
    print('Convert to openfst')
    cmd=[finddlp(),*grm2ofstarg(fin)]
    subprocess.run(cmd,check=True)
    # save the intermediate file also for illustrational purposes
    subprocess.run(['cp',fout,fout+".save.txt"],check=True)

grm=loadgrm(fout,sub=ofstin)
mergesubgrms(grm,dn,usestk=usestk)
grmsymupper(grm)
if addpau: grmaddpau(grm)
if dbg: grmmapistoos(grm)
grmapplylmw(grm,lmw)
savegrm(fout,grm)

if not ofstin: savelex(flex,fin)

