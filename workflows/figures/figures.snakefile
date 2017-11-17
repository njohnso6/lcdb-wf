import sys
sys.path.insert(0, srcdir('../..'))
import os
from lcdblib.utils import utils
from lib import common
from lib.patterns_targets import RNASeqConfig, ChIPSeqConfig

rnaseq_config = RNASeqConfig('../rnaseq/config/test_config.yaml')
chipseq_config = ChIPSeqConfig('../chipseq/config/test_chipseq_config.yaml')


subworkflow rnaseq:
    snakefile: '../rnaseq/rnaseq.snakefile'
    configfile: rnaseq_config.path
    workdir: '../rnaseq'


subworkflow chipseq:
    snakefile: '../chipseq/chipseq.snakefile'
    configfile: chipseq_config.path
    workdir: '../chipseq'


rule peak_count:
    input: chipseq(utils.flatten(chipseq_config.targets['peaks']))
    output: 'figures/peak_count/peak_count.tsv'
    run:
        import pandas as pd
        import pybedtools
        df = []
        for i in input:
            toks = i.split('/')
            peakcaller = toks[-3]
            label = toks[-2]
            df.append(dict(peakcaller=peakcaller, label=label, count=len(pybedtools.BedTool(i))))
        pd.DataFrame(df)[['peakcaller', 'label', 'count']].to_csv(output[0], sep='\t', index=False)



# vim: ft=python
