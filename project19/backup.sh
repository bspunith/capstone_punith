#!/bin/bash

aws s3 cp ~/project19/logs/app.log \
s3://project19-backup-0101/app.log
