FROM rocker/geospatial:3.5.2

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libudunits2-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libudunits2-dev \
    libgdal-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ARG GITHUB_PAT

RUN set -x && \
  echo "GITHUB_PAT=$GITHUB_PAT" >> /usr/local/lib/R/etc/Renviron

RUN set -x && \
  install2.r --error \
    here \
    jpmesh \
    rmarkdown \
    leaflet \
    rvest \
    tabulizer \
    testthat \
    devtools && \
  installGithub.r \
    uribo/jpmesh && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds

