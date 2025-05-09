#!/bin/bash
jq -S . mapping.json | sponge mapping.json
