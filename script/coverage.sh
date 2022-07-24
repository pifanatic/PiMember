#!/bin/bash

rm -rf cover_db

HARNESS_PERL_SWITCHES=-MDevel::Cover prove

cover
