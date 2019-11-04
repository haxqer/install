#!/bin/bash

find / -xdev -type f -size +10M | xargs ls -lh

