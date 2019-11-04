#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

find ${DIR}/../ -name "*.sh" | xargs -I@ chmod +x @

