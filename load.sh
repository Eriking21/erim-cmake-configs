#!/bin/bash
find "$(cd "$(dirname "$0")" && pwd)"  -maxdepth 1  -type f ! -name "load*" -exec ln -t . {} +