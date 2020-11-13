#!/bin/sh

sensors | grep Tctl | cut -d '+' -f 2
