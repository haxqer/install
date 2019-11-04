#!/bin/bash


find / -xdev -type f -size +1000M | xargs ls -lh

