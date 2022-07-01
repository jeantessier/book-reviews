#!/bin/sh

\rm -R node_modules package-lock.json
npm --workspaces install
