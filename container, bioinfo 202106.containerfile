# syntax=docker/dockerfile:1
FROM gnome:202106
# install R, RStudio, frequently used R packages
RUN zypper refresh ; \
    zypper --non-interactive dist-upgrade ; \
    zypper --non-interactive install R-base rstudio-desktop ; \
    zypper clean --all ;
# install miniconda (Miniconda3-latest-Linux-x86_64.sh, py38_4.9.2 at 20210626)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.9.2-Linux-x86_64.sh --verbose --tries=3 --output-document=/tmp/miniconda3.sh && \
    bash /tmp/miniconda3.sh -b -p /miniconda3/ -t && \
    rm /tmp/miniconda3.sh && \
    echo -e "\nexport PATH=/miniconda3/bin/:\$PATH\n" >> /home/UserA/.bashrc && \
    echo -e "\nexport PATH=/miniconda3/bin/:\$PATH\n" >> /home/UserB/.bashrc && \
    echo -e "\nexport PATH=/miniconda3/bin/:\$PATH\n" >> /root/.bashrc && \
    /miniconda3/bin/conda config --prepend channels conda-forge && \
    /miniconda3/bin/conda config --prepend channels bioconda && \
#   /miniconda3/bin/conda config --set channel_priority disable && \
#   /miniconda3/bin/conda config --set channel_priority strict && \
    /miniconda3/bin/conda update --update-all --yes ;
# install app via conda
RUN conda install --yes --verbose iqtree mrbayes phyml raxml ; \
    conda install --yes --verbose bcftools bwa novoplasty plink2 samtools snpeff spades vcftools ; \
    which {iqtree,mb,phyml,raxmlHPC} && \
    which {bcftools,bwa,NOVOPlasty.pl,plink2,samtools,snpEff,spades.py,vcftools} ;
# install other bioinfo app into /opt/ (and add /opt/bin/ to PATH in ~/{.bashrc,.profile})
RUN mkdir --verbose /opt/bin/
# structure (https://web.stanford.edu/group/pritchardlab/structure_software/release_versions/v2.3.4/release/structure_linux_frontend.tar.gz)
# PHASE (http://stephenslab.uchicago.edu/assets/software/phase/phasecode/phase.2.1.1.linux.tar.gz)
# blastr blastx GapCloser SOAPnuke
# conda search *blast*

