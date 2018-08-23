#!/bin/bash

# Compress to GZIP by Tar
tar cvfz cnee_events.tar.gz ./default_event.xnr ./browser_event.xnr
#tar cvfz cnee_events.tar.gz ./default_event.xnr ./browser_event.xnr ./benchmark_event.xnr

# Move UseCase File
mv ./cnee_events.tar.gz ../../

